module Skylab::FileMetrics

  class API::Actions::LineCount

    extend API::Common::ModuleMethods

    include API::Common::InstanceMethods

    def run
      res = false
      begin
        @path_a = @req[:paths]
        file_a = get_file_a or break
        @ui.err.puts file_a if @req[:show_file_list]
        if ! @req[:show_report]
          break( res = true )
        else
          c = count_lines( file_a ) or break
          if c.zero_children?
            @ui.err.puts "(no files)"
          else
            c.collapse_and_distribute
            render_table c, @ui.err
          end
        end
      end while false
      res
    end

    LineCount = FileMetrics::Models::Count.subclass :total_share, :max_share,
      :lipstick, :lipstick_float

  private

    def get_file_a
      res_a = [ ]
      y = ::Enumerator::Yielder.new do |line|  # (just grease the wheels..)
        res_a << line
      end
      @path_a.reduce y do |path_y, path|
        st = begin ::File::Stat.new( path ) ; rescue ::Errno::ENOENT => e ; end
        if ! st
          @ui.err.puts "skipping - #{ e.message.sub(/^[A-Z]/) {$~[0].downcase}}"
        elsif st.file?
          path_y << path
        elsif st.directory?
          files_in_dir path, path_y or break
        end
        path_y
      end
      res_a
    end

    def files_in_dir path, line_y
      cmd = build_find_files_command @path_a
      if cmd
        cmd_string = cmd.string
        if @req[:show_commands] || @req.fetch( :debug_volume )
          @ui.err.puts cmd_string
        end
        stdout_lines cmd_string, line_y
      end
    end

    -> do  # `render_table`

      percent = -> v { "%0.2f%%" % ( v * 100 ) }

      define_method :render_table do |count, out|
        rndr_tbl out, count, -> do
          fields [
            [ :label,               header: 'File' ],
            [ :count,               header: 'Lines' ],
            [ :rest,                :rest ],  # if we forgot any fields, glob them here
            [ :total_share,         prerender: percent ],
            [ :max_share,           prerender: percent ],
            [ :lipstick_float,      :noop ],
            [ :lipstick,            FileMetrics::CLI::Lipstick.instance.field_h ]
          ]
          field[:label].summary -> do
              "Total: #{ count.child_count }"
            end, -> do
              fail "helf"
            end
          field[:count].summary -> do
              "%d" % count.sum_of( :count )
            end
          field[:lipstick].summary nil
        end
      end
      private :render_table
    end.call
  end
end
