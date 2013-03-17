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
            render_table count, @ui.err
          end
        end
      end while false
      res
    end

    LineCount = Models::Count.subclass :total_share, :max_share, :lipstick

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

    Stream_ = ::Struct.new :io, :func

    def files_in_dir path, file_a
      cmd = build_find_command
      if cmd
        cmd_string = cmd.string
        if @req[:show_commands] || @req.fetch( :debug_volume )
          @ui.err.puts cmd_string
        end
        # overblown but neat algo -
        ok = FileMetrics::Services::Open3.popen3 cmd_string do |_, sout, serr|
          er = nil
          hot_a = [
            Stream_[ sout, -> ln { file_a << ln } ],
            Stream_[ serr, -> ln do
              er ||= true
              @ui.err.puts "(find errorr? - \"#{ ln }\")"
            end ] ]
          begin
            (( hot_a.length - 1 ).downto 0 ).each do |idx|
              stream = hot_a[idx]
              line = stream.io.gets
              if line
                line.chomp!
                stream.func[ line ]
              else
                hot_a[ idx ] = nil  # why we do it backwards NOTE
                hot_a.compact!
              end
            end
          end while hot_a.length.nonzero?
          ! er
        end
        ok
      end
    end

    def build_find_command
      Models::FindCommand.valid -> c do
        c.concat_paths @path_a
        c.concat_skip_dirs @req[:exclude_dirs]
        c.concat_names @req[:include_names]
        c.extra = '-not -type d'
      end, method( :error )
    end

    -> do  # `render_table`

      percent = -> v { "%0.2f%%" % ( v * 100 ) }

      define_method :render_table do |count, out|
        rndr_tbl count, out, [ :fields,
          [ :label,       header: 'File' ],
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
