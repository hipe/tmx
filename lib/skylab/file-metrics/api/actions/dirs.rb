module Skylab::FileMetrics

  class API::Actions::Dirs

    extend API::Common::ModuleMethods

    include API::Common::InstanceMethods

    def run
      count = Models::Count.new("folders summary")
      find_cmd = build_find_dirs_command
      @req[:show_commands] and @ui.err.puts(find_cmd)
      dirs = %x{#{find_cmd}}.split("\n")
      if @req[:show_files_list] || @req.fetch( :debug_volume )
        @ui.err.puts( dirs )
      end
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
        _folder_count.count ||= 0
        count.add_child _folder_count
      end
      if count.zero_children?
        @ui.err.puts "(no children)"
        nil
      else
        count.collapse_and_distribute do |child|
          child.set_field :num_files, child.nonzero_children?  # ick / meh
          child.set_field :num_lines, child.count # just to be clear
        end
      end
      count.display_summary_for :label do |_| "Total:" end
      count.display_summary_for :lipstick do |_| nil end
      count.display_total_for(:num_files) { |d| "%d" % d if d }
      count.display_total_for(:num_lines) { |d| "%d" % d if d }
      render_table count, @ui.err
    end

    # (we are trying to keep some ancient code for posterity for now ..)
    Models_ = Models
    module Models
      Count = FileMetrics::Models::Count.subclass :total_share,
        :max_share, :lipstick
    end

    LineCount = Models::Count

  protected

    def build_find_dirs_command
      cmd = Models_::FindCommand.valid( -> c do
        c.add_path @req[:path]
        c.concat_skip_dirs @req[:exclude_dirs]
        c.concat_names @req[:include_names]
        c.extra = '-a -maxdepth 1 -type d'
      end, -> msg do
        fail "no - #{ msg }"
      end ).string
    end

    def build_find_files_command path
      Models_::FindCommand.valid -> c do
        c.add_path path
        c.concat_skip_dirs @req[:exclude_dirs]
        c.concat_names @req[:include_names]
        c.extra = '-not -type d'
      end, method( :error )
    end

    -> do  # `render_table`

      percent = -> v { "%0.2f%%" % ( v * 100 ) if v }

      define_method :render_table do |count, out|
        rndr_tbl count, out, [ :fields,
          [ :label,       header: 'Directory' ],
          [ :count,       header: 'Lines' ],
          [ :total_share, filter: percent ],
          [ :max_share,   filter: percent ],
          [ :lipstick,    :autonomous, header: '' ]
        ]
      end
      protected :render_table
    end.call
  end
end
