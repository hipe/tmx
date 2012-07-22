require File.expand_path('../common.rb', __FILE__)

module Skylab::FileMetrics

  class API::LineCount
    extend API::CommonModuleMethods
    include API::CommonInstanceMethods

    def run
      @paths = @req[:paths]
      files = self.files
      @req[:show_files_list] and @ui.err.puts(files)
      @req[:show_report] or return true
      count = count_lines files
      if ! count.children?
        @ui.err.puts "no files found."
      else
        total = count.total.to_f
        count.sort_children_by! { |c| -1 * c.total }
        max = count.children.map(&:total).max.to_f
        count.children.each do |c|
          c.set_field(:total_share, c.total.to_f / total)
          c.set_field(:max_share, p = c.total.to_f / max)
          c.set_field(:lipstick, p)
        end
        count.display_total_for(:count) { |num| "total: %d" % num }
        render_table count, @ui.err
      end
    end
  protected
    def build_find_command
      Models::FindCommand.build do |f|
        f.paths = @paths
        f.skip_dirs = @req[:exclude_dirs]
        f.names = @req[:include_names]
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
      @req[:show_commands] and @ui.err.puts(cmd)
      `#{cmd}`.split("\n")
    end

    def render_table count, out
      _percent = ->(v) { "%0.2f%%" % (v * 100) }
      _render_table(count, out,
        count:        { label: 'Lines' },
        total_share:  { filter: _percent },
        max_share:    { filter: _percent },
        lipstick:     { label: '', filter: ->(x) { x } }
      )
    end
  end
end
