require File.expand_path('../common', __FILE__)

module Skylab::FileMetrics

  class API::Dirs
    extend API::CommonModuleMethods
    include API::CommonInstanceMethods

    def run
      count = Models::Count.new("folders summary")
      find_cmd = build_find_dirs_command
      @req[:show_commands] and @ui.err.puts(find_cmd)
      dirs = %x{#{find_cmd}}.split("\n")
      @req[:show_files_list] and @ui.err.puts(dirs)
      dirs.each do |dir|
        _files = %x{#{build_find_files_command(dir)}}.split("\n")
        _dir_count = Models::Count.new(dir, nil)
        _ok_files = []; _errs = []
        _files.each do |f|
          if File.exist?(f)
            if File.readable?(f)
              _ok_files.push(f)
            else
              _dir_count.add_child(Models::Count.new(f, nil, :notice => "not readable"))
            end
          else
            _dir_count.add_child(Models::Count.new(f, nil, :notice => "bad link"))
          end
        end
        _folder_count = count_lines(_ok_files, File.basename(dir))
        _folder_count.total.nil? and _folder_count.total = 0
        count.add_child _folder_count
      end
      total = count.total.to_f
      if count.children.nil?
        @ui.err.puts "(no children)"
        return
      end
      count.sort_children_by! { |c| -1 * c.total }
      max = count.children.map(&:total).max.to_f
      count.children.each do |o|
        o.set_field(:num_files, o.children ? o.children.size : nil)
        o.set_field(:num_lines, o.total)
        o.set_field(:total_share, o.total.to_f / total)
        o.set_field(:max_share, o.total.to_f / max)
      end
      count.display_summary_for(:name) { "Total:" }
      count.display_total_for(:num_files) { |d| "%d" % d }
      count.display_total_for(:num_lines) { |d| "%d" % d }
      render_table count, @ui.err
    end
  private
    def build_find_dirs_command
      Models::FindCommand.build do |o|
        o.paths = [@req[:path]]
        o.skip_dirs = @req[:exclude_dirs]
        o.names = @req[:include_names]
        o.extra = ' -a -maxdepth 1 -type d'
      end
    end
    def build_find_files_command path
      Models::FindCommand.build do |f|
        f.paths = [path]
        f.skip_dirs = @req[:exclude_dirs]
        f.names = @req[:include_names]
        f.extra = '-not -type d'
      end
    end
    def render_table count, out
      labels = {
        :count => 'Lines'
      }
      percent = lambda { |v| "%0.2f%%" % (v * 100) }
      filters = {
        :total_share => percent,
        :max_share   => percent
      }
      _render_table count, out, labels, filters
    end
  end
end
