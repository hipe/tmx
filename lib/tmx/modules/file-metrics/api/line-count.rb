require File.expand_path('../../api', __FILE__)

module Skylab::Tmx::Modules::FileMetrics

  class Api::LineCount
    include PathTools
    def self.run paths, opts, ui
      new(paths, opts, ui).run
    end
    def initialize paths, opts, ui
      @paths, @opts, @ui = [paths, opts, ui]
      # do defaults, normalization now, once in case we want to re-run for some awful reason
      @paths.empty? and @paths.push('.')
    end
    def run
      files = self.files
      @opts[:show_files_list] and @ui.err.puts(files)
      @opts[:show_report] or return true
      count =
      if @opts[:count_blank_lines] && @opts[:count_comment_lines]
        linecount_using_wc files
      else
        fail("pending implementation @todo")
      end
      if count.no_children?
        @ui.err.puts "no files found."
      else
        total = count.total.to_f
        count.sort_children_by! { |c| -1 * c.total }
        max = count.children.map(&:total).max.to_f
        count.children.each { |c| c.set_field(:total_share, c.total.to_f / total ) }
        count.children.each { |c| c.set_field(:max_share, c.total.to_f / max ) }
        tableize count, @ui.err
      end
    end
  protected
    def build_find_command
      FindCommand.build do |f|
        f.paths = @paths
        f.skip_dirs = @opts[:exclude_dirs]
        f.names = @opts[:include_names]
        f.extra = '-not -type d'
      end
    end

    def files
      tree = []
      @paths.each do |path|
        if File.directory? path
          tree.push [:directory, path, files_in_dir(path)]
        elsif File.file? path
          tree.push [:file, path]
        else
          @ui.err.puts "not a file or directory, skipping: #{path}"
        end
      end
      tree.map{ |n| n.first == :file ? n[1] : n[2] }.flatten
    end

    def files_in_dir path
      cmd = build_find_command
      @opts[:show_commands] and @ui.err.puts(cmd)
      `#{cmd}`.split("\n")
    end

    def linecount_using_wc files
      count = Count.new('.')
      files.empty? and return count
      _ = "wc -l #{files.map{ |x| escape_path(x) } * ' '} | sort -g"
      @opts[:show_commands] and @ui.err.puts(_)
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
        end,
        out
      )
    end
  end
end
