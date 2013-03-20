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
        cmd = build_find_files_command( [ dir ] ) or break
        stdout_lines cmd.string, ( _files = [] ) or break
        # (for fun, leaving below antique lines intact as long as possible!)
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
          child.set_field :num_lines, child.count  # just to be clear
        end
        count.display_summary_for :label do "Total:" end
        count.display_summary_for :lipstick do nil end
        count.display_total_for :num_files do |d| "%d" % d if d end
        count.display_total_for :num_lines do |d| "%d" % d if d end
      end
      render_table count, @ui.err
    end

    # (we are trying to keep some ancient code for posterity for now ..)
    module Models
      Count = FileMetrics::Models::Count.subclass :num_files,
        :num_lines, :total_share, :max_share, :lipstick_float, :lipstick
    end

    LineCount = Models::Count

  protected

    def build_find_dirs_command
      cmd = Services::Find.valid( -> c do
        c.add_path @req[:path]
        c.concat_skip_dirs @req[:exclude_dirs]
        c.concat_names @req[:include_names]
        c.extra = '-a -maxdepth 1 -type d'
      end, -> msg do
        fail "no - #{ msg }"
      end ).string
    end

    -> do  # `render_table`

      percent = -> v { "%0.2f%%" % ( v * 100 ) if v }

      define_method :render_table do |count, out|
        rndr_tbl count, out, [ :fields,
          [ :label,       header: 'Directory' ],
          [ :count,       :noop ],
          [ :num_files,   filter: -> x { x.to_s } ],
          [ :num_lines,   filter: -> x { x.to_s } ],
          [ :rest,        :rest ],  # any fields not stated here, glob them
          [ :total_share, filter: percent ],
          [ :max_share,   filter: percent ],
          [ :lipstick_float, :noop ],
          [ :lipstick,    :autonomous, header: '' ]
        ]
      end
      protected :render_table
    end.call
  end
end
