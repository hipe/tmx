require File.expand_path('../../api', __FILE__)

module Skylab::Tmx::Modules::FileMetrics
  class Api::Dirs
    include PathTools
    include CommonCommandMethods

    def self.run(ui, req)
      new(ui, req).run
    end
    def initialize *a
      @ui, @req = a
    end
    def run
      count = Count.new("folders summary")
      find_cmd = build_find_dirs_command
      @req[:show_commands] and @ui.err.puts(find_cmd)
      dirs = %x{#{find_cmd}}.split("\n")
      @req[:show_files_list] and @ui.err.puts(dirs)
      dirs.each do |dir|
        _files = %x{#{build_find_files_command(dir)}}.split("\n")
        _dir_count = Count.new(dir, nil)
        _ok_files = []; _errs = []
        _files.each do |f|
          if File.exist?(f)
            if File.readable?(f)
              _ok_files.push(f)
            else
              _dir_count.add_child(Count.new(f, nil, :notice => "not readable"))
            end
          else
            _dir_count.add_child(Count.new(f, nil, :notice => "bad link"))
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
      tableize count, @ui.err
    end
  private
    def build_find_dirs_command
      FindCommand.build do |o|
        o.paths = [@req[:path]]
        o.skip_dirs = @req[:exclude_dirs]
        o.names = @req[:include_names]
        o.extra = ' -a -maxdepth 1 -type d'
      end
    end
    def build_find_files_command path
      FindCommand.build do |f|
        f.paths = [path]
        f.skip_dirs = @req[:exclude_dirs]
        f.names = @req[:include_names]
        f.extra = '-not -type d'
      end
    end
  end
end
