o = File.expand_path('../..', __FILE__)
require "#{o}/count"
require "#{o}/find-command"
require "#{o}/table"

module Skylab::FileMetrics

  module API
   class RuntimeError         < ::RuntimeError; end
   class SystemInterfaceError <   RuntimeError; end
  end


  module API::CommonModuleMethods
    def run(*a) ; new(*a).run ; end
  end

  module API::CommonInstanceMethods
    include Common::PathTools

    def initialize *a
      @ui, @req = a
    end

    def count_lines files, label=nil
      (_filters =
      [ (%s{grep -v '^[ \t]*$'} unless @req[:count_blank_lines]),
        (%s{grep -v '^[ \t]*#'} unless @req[:count_comment_lines])
      ].compact).empty? and return linecount_using_wc(files)
      cmd_tail = "#{_filters.join(' | ')} | wc -l"
      count = Models::Count.new(label || '.') # count.add_child(Models::Count.new($2, $1.to_i))
      files.each do |file|
        cmd = "cat #{escape_path(file)} | #{cmd_tail}"
        @req[:show_commands] and @ui.err.puts(cmd)
        _ = %x{#{cmd}}
        if _ =~ /\A[[:space:]]*(\d+)[[:space:]]*\z/
          count.add_child(Models::Count.new(file, $1.to_i))
        else
          count.add_child(Models::Count.new(file, 0, :notice => "(parse failed: #{_})"))
        end
      end
      count
    end

    def linecount_using_wc files
      count = Models::Count.new('.')
      files.empty? and return count
      _ = "wc -l #{files.map{ |x| escape_path(x) } * ' '} | sort -g"
      @req[:show_commands] and @ui.err.puts(_)
      lines = `#{_}`.split("\n")
      case lines.size
      when 0
        raise SystemInterfaceError.new("never")
      when 1
        /\A *(\d+) (.+)\z/ =~ lines.first or
          raise SystemInterfaceError.new("regex failed to match: #{lines.first}")
        count.add_child(Models::Count.new($2, $1.to_i))
        # truncated form looses information:
        # count.name = $2; count.count = $1.to_i
      else
        lines[0..-2].each do |line|
          /\A *(\d+) (.+)\z/ =~ line or
            raise SystemInterfaceError.new("regex failed to match: #{line}")
          count.add_child(Models::Count.new($2, $1.to_i))
        end
        (/\A *(\d+) total\z/ =~ lines.last and $1.to_i) or
          raise SystemInterfaceError.new("regex failed to match: #{lines.last}")
        count.total = $1.to_i # might as well use this one and not calculate it ourselves
      end
      count
    end
    def _render_table count, out, labels, filters
      unless count.children?
        out.puts "(table has no rows)"
        return false
      end
      labels[:_default] ||= lambda { |f| f.to_s.split('_').map(&:capitalize).join(' ') }
      header_row = count.children.first.fields.map do |f|
        v = labels.key?(f) ? labels[f] : labels[:_default]
        v.kind_of?(Proc) ? v.call(f) : v
      end
      rows = count.children.map do |_count|
        _count.fields.map do |field|
          v = _count.send(field)
          filters.key?(field) ? filters[field].call(v) : v.to_s
        end
      end
      rows = [header_row] + rows + count.summary_rows
      Models::Table.render rows, out
    end
  end
end
