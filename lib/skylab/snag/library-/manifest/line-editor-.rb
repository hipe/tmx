module Skylab::Snag

  class Library_::Manifest

    class Line_editor_ < Funcy_

      Entity_[ self, :fields,

        :at_position_x,  # when it is zero it means "insert the new lines at
        # the begnning of the file" else it is expected to be a rendered
        # identifier, for which the the lines will replace the existing lines
        # for that node.

        :new_line_a,  # insert or replace

        :is_dry_run, :verbose_x,  # options

        :manifest_file_p,  # the model of the file, for our persistence impl.
        :pathname,  # #todo - redundant with above

        :tmpdir_p,  # used for our persistence implementation
        :file_utils_p, # ditto
        :escape_path_p,  # #eew should be curried into above

        :error_p, # may be called when e.g the node is not found
        :info_p,  # called for e.g verbose output or informational.
        :raw_info_p  # probably lines to be written directly to stderr
      ]

      def execute
        r = nil
        begin
          r = prepare or break
          r = commit
        end while nil
        r
      end

    private

      def prepare
        @new_line_a.length.zero? and fail "sanity - zero new lines"
        @manifest_file = @manifest_file_p.call
        @fu = @file_utils_p[ :escape_path_p, @escape_path_p, :be_verbose,
                             @verbose_x, :info_p, @info_p ]
        @tmpdir = @tmpdir_p[ :is_dry_run, @is_dry_run, :file_utils, @fu,
                             :error_p, @error_p ]
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
        begin
          @tmpnew.exist? and rm @tmpnew
          @scn = @manifest_file.normalized_line_producer  # #open-filehandle
          p = r = if 0 == @at_position_x
            get_prepend_lines_p
          else
            get_change_lines_p
          end
          p or break
          r = flush_lines p
        end while nil
        r
      end

      Build_context_sensitive_line_writer_ = -> fh do

        # when you save a file in vi it appears to append a a "\n" to the
        # last line if there was not one already. we follow suit here when
        # rewriting the manifest. however we leave the below in place in case
        # we ever decide to revert back to the dumb way.

        # sep = nil
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
            info "new line: #{ @new_line_a.fetch 0 }"
          else
            info "new lines:"
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
