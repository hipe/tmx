module Skylab::Snag

  class Models::Manifest

    class Line_edit_ < Agent_  # see [#038]

      Entity_[ self, :fields,  # all fields below are explained in the doc node.
        :at_position_x,
        :error_event_p,
        :escape_path_p,
        :file_utils_p,
        :info_event_p,
        :is_dry_run,
        :manifest_file_p,
        :new_line_a,
        :pathname,
        :raw_info_p,
        :tmpdir_p,
        :verbose_x,
      ]

      def execute
        ok = prepare
        ok && commit
      end

    private

      def prepare
        @new_line_a.length.zero? and fail "sanity - zero new lines"
        @manifest_file = @manifest_file_p.call
        @fu = @file_utils_p[ :escape_path_p, @escape_path_p, :be_verbose,
                             @verbose_x, :info_event_p, @info_event_p ]
        @tmpdir = @tmpdir_p[ :is_dry_run, @is_dry_run, :file_utils, @fu,
                             :error_event_p, @error_event_p ]
        @tmpold = @tmpdir.join 'issues.prev.md'
        @tmpnew = @tmpdir.join 'issues-next.md'
        @rm = -> pn do
          @fu.rm pn, noop: @is_dry_run
        end
        @mv = -> a, b do
          @fu.mv a, b, noop: @is_dry_run
        end
        true
      end

      def commit
          @tmpnew.exist? and rm @tmpnew
          @scn = @manifest_file.normalized_line_producer  # #open-filehandle
          p = if 0 == @at_position_x
            get_prepend_lines_p
          else
            get_change_lines_p
          end
          p and flush_lines p
      end

      Build_context_sensitive_line_writer_ = -> fh do

        # sep = nil  # #note-73
        -> line do
          # fh.write "#{ sep }#{ line }"
          # sep ||= "\n" # meh [#020]
          fh.write "#{ line }#{ NL_ }"
          nil
        end
      end

      NL_ = "\n".freeze

      def get_prepend_lines_p
        # simply rewrite the file line-by-line, putting new lines at top
        -> do
          if 1 == @new_line_a.length
            info_string "new line: #{ @new_line_a.fetch 0 }"
          else
            info_string "new lines:"
            many = true
          end
          @new_line_a.each do |line|
            @raw_info_p[ line ] if many
            @write_line_p[ line ]
          end
          while (( line = @scn.gets ))
            @write_line_p[ line ]
          end
          true
        end
      end

      def get_change_lines_p
        -> do
          id_str = @at_position_x
          len = id_str.length
          while (( line = @scn.gets ))
            if id_str == line[ 0, len ]
              break( r = replace_and_rewrite )
            end
            @write_line_p[ line ]
          end
          r || bork( "node lines not found for node with identifier #{
            }#{ id_str }" )
        end
      end

      def replace_and_rewrite
        while (( line = @scn.gets ))
          SPACE_RX_ =~ line or break
        end
        @new_line_a.each do |lin|
          @write_line_p[ lin ]
        end
        line and @write_line_p[ line ]
        while (( line = @scn.gets ))
          @write_line_p[ line ]
        end
        true
      end

      SPACE_RX_ = /^[[:space:]]/

      def rm x
        @rm[ x ]
      end

      def flush_lines flush_p
        ( @is_dry_run ? DEV_NULL_ : @tmpnew ).open WRITEMODE_ do |fh|
          @write_line_p = Build_context_sensitive_line_writer_[ fh ]
          flush_p[]
        end
        @tmpold.exist? and rm @tmpold
        mv @pathname, @tmpold
        mv @tmpnew, @pathname
        true
      end

      def mv x, y
        @mv[ x, y ]
      end

      DEV_NULL_ = Snag_::Lib_::Dev_null[]
      WRITEMODE_ = Snag_::Lib_::Writemode[]

    end
  end
end
