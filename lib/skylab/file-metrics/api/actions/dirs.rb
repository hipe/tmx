module Skylab::FileMetrics

  class API::Actions::Dirs

    extend API::Common::ModuleMethods

    include API::Common::InstanceMethods

    def run
      c = Models::Count.new("folders summary")
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
        c.add_child _folder_count
      end
      if c.zero_children?
        @ui.err.puts "(no dirs)"
        nil
      else
        c.collapse_and_distribute do |cx|
          cx.set_field :num_files, cx.nonzero_children?  # ick / meh
          cx.set_field :num_lines, cx.count  # just to be clear
        end
      end
      render_table c, @ui.err
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

        rndr_tbl out, count, -> do
          fields [
            [ :label,               header: 'Directory' ],
            [ :count,               :noop ],
            [ :num_files,           prerender: -> x { x.to_s } ],
            [ :num_lines,           prerender: -> x { x.to_s } ],
            [ :rest,                :rest ],  # any fields not stated here, glob them
            [ :total_share,         prerender: percent ],
            [ :max_share,           prerender: percent ],
            [ :lipstick_float,      :noop ],
            [ :lipstick,            FileMetrics::CLI::Lipstick::FIELD ]
          ]
          field[:label].summary -> do
            'Total: '
          end, -> do
            fail 'me'
          end
          field[:num_files].summary -> do
            "%d" % count.sum_of( :num_files )
          end
          field[:num_lines].summary -> do
            "%d" % count.sum_of( :num_lines )
          end
          field[:lipstick].summary nil
        end
      end
    end.call
    protected :render_table
  end
end
