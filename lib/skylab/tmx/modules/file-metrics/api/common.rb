o = File.expand_path('../..', __FILE__)
require "#{o}/count"
require "#{o}/find-command"
require "#{o}/path-tools"
require "#{o}/table"

module Skylab::Tmx::Modules::FileMetrics

  module Api
   class RuntimeError         < ::RuntimeError; end
   class SystemInterfaceError <   RuntimeError; end
  end

  module CommonCommandMethods

    def count_lines files, label=nil
      (_filters =
      [ (%s{grep -v '^[ \t]*$'} unless @req[:count_blank_lines]),
        (%s{grep -v '^[ \t]*#'} unless @req[:count_comment_lines])
      ].compact).empty? and return linecount_using_wc(files)
      cmd_tail = "#{_filters.join(' | ')} | wc -l"
      count = Count.new(label || '.') # count.add_child(Count.new($2, $1.to_i))
      files.each do |file|
        cmd = "cat #{escape_path(file)} | #{cmd_tail}"
        @req[:show_commands] and @ui.err.puts(cmd)
        _ = %x{#{cmd}}
        if _ =~ /\A[[:space:]]*(\d+)[[:space:]]*\z/
          count.add_child(Count.new(file, $1.to_i))
        else
          count.add_child(Count.new(file, 0, :notice => "(parse failed: #{_})"))
        end
      end
      count
    end

    def linecount_using_wc files
      count = Count.new('.')
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
        count.add_child(Count.new($2, $1.to_i))
        # truncated form looses information:
        # count.name = $2; count.count = $1.to_i
      else
        lines[0..-2].each do |line|
          /\A *(\d+) (.+)\z/ =~ line or
            raise SystemInterfaceError.new("regex failed to match: #{line}")
          count.add_child(Count.new($2, $1.to_i))
        end
        (/\A *(\d+) total\z/ =~ lines.last and $1.to_i) or
          raise SystemInterfaceError.new("regex failed to match: #{lines.last}")
        count.total = $1.to_i # might as well use this one and not calculate it ourselves
      end
      count
    end

    def tableize count, out
      return unless count.any_children?
      Table.render(
        [count.children.first.fields.map do |f|
          f = case f
          when :count ; 'Lines'
          else f
          end
          f.to_s.split('_').map(&:capitalize).join(' ')
        end] +
        count.children.map do |_count|
          _count.fields.map do |field|
            case field
            when :total_share, :max_share
              "%0.2f%%" % (_count.send(field) * 100)
            else
              _count.send(field).to_s
            end
          end
        end + count.summary_rows,
        out
      )
    end
  end
end
