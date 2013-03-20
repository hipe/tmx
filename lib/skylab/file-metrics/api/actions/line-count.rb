module Skylab::FileMetrics

  class API::Actions::LineCount

    extend API::Common::ModuleMethods

    include API::Common::InstanceMethods

    def run
      res = false
      begin
        @path_a = @req[:paths]
        file_a = self.file_a or break
        @ui.err.puts file_a if @req[:show_file_list]
        if ! @req[:show_report]
          break( res = true )
        else
          count = count_lines( file_a ) or break
          if count.zero_children?
            @ui.err.puts "no files found."
          else
            count.collapse_and_distribute
            count.display_summary_for :label do "Total:" end
            count.display_total_for :count do |d| "%d" % d if d end
            render_table count, @ui.err
          end
        end
      end while false
      res
    end

    LineCount = Models::Count.subclass :total_share, :max_share, :lipstick,
      :lipstick_float

  protected

    def file_a
      @path_a.reduce [] do |file_a, path|
        st = begin ::File::Stat.new( path ) ; rescue ::Errno::ENOENT => e ; end
        if ! st
          @ui.err.puts "skipping - #{ e.message.sub(/^[A-Z]/) {$~[0].downcase}}"
        elsif st.file?
          file_a << path
        elsif st.directory?
          files_in_dir path, file_a or break
        end
        file_a
      end
    end

    def files_in_dir path, file_a
      cmd = build_find_files_command @path_a
      if cmd
        cmd_string = cmd.string
        if @req[:show_commands] || @req.fetch( :debug_volume )
          @ui.err.puts cmd_string
        end
        stdout_lines cmd_string, file_a
      end
    end

    -> do  # `render_table`

      percent = -> v { "%0.2f%%" % ( v * 100 ) }

      define_method :render_table do |count, out|
        rndr_tbl count, out, [ :fields,
          [ :label,       header: 'File' ],
          [ :count,       header: 'Lines' ],
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
