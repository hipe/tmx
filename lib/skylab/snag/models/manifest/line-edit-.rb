module Skylab::Snag

  class Models::Manifest

    class Line_edit_ < Agent_  # see [#038]

      Entity_[ self, :fields,  # #note-9 explains all fields
        :at_position_x,
        :is_dry_run,
        :new_line_a,
        :verbose_x,
        :client,
        :delegate ]

      def execute
        ok = prepare
        ok && commit
      end

    private

      def prepare
        @new_line_a.length.zero? and self._SANITY
        @manifest_file = @client.manifest_file
        @manifest_file_pn = @manifest_file.pathname
        @fu = @client.build_file_utils(
          :be_verbose, @verbose_x,
          :delegate, @delegate )
        @tmpdir = @client.produce_tmpdir(
          :is_dry_run, @is_dry_run,
          :file_utils, @fu,
          :delegate, @delegate )
        @tmpold = @tmpdir.join 'issues.prev.md'
        @tmpnew = @tmpdir.join 'issues-next.md'
        ACHIEVED_
      end

      def commit
        @tmpnew.exist? and rm @tmpnew
        @scn = @manifest_file.normalized_line_producer  # #open-filehandle
        flush_lines( if 0 == @at_position_x
          :prepend_lines
        else
          :change_lines
        end )
      end

      def flush_lines flush_lines_method_i
        ( @is_dry_run ? DEV_NULL_ : @tmpnew ).open WRITE_MODE_ do |fh|
          @write_line_p = Build_context_sensitive_line_writer__[ fh ]
          send flush_lines_method_i
        end
        @tmpold.exist? and rm @tmpold
        mv @manifest_file_pn, @tmpold
        mv @tmpnew, @manifest_file_pn
        ACHIEVED_
      end

      def mv src_pn, dest_pn
        @fu.mv src_pn.to_path, dest_pn.to_path, noop: @is_dry_run
      end

      Build_context_sensitive_line_writer__ = -> fh do
        # sep = nil  # #note-73, :+[#020]
        -> line do
          # fh.write "#{ sep }#{ line }"
          # sep ||= "\n"
          fh.write "#{ line }#{ LINE_SEP_ }"
          nil
        end
      end

      def rm pn
        @fu.rm pn.to_path, noop: @is_dry_run
      end

      def prepend_lines
        # simply rewrite the file line-by-line, putting new lines at top
        if 1 == @new_line_a.length
          send_info_string "added new line: #{ @new_line_a.fetch 0 }"
        else
          send_info_string "added new lines:"
          is_multiple = true
        end
        @new_line_a.each do |line|
          is_multiple and @delegate.receive_info_line line
          @write_line_p[ line ]
        end
        while (( line = @scn.gets ))
          @write_line_p[ line ]
        end
        ACHIEVED_
      end

      def change_lines
        id_str = @at_position_x
        len = id_str.length
        while (( line = @scn.gets ))
          if id_str == line[ 0, len ]
            break( ok = replace_and_rewrite )
          end
          @write_line_p[ line ]
        end
        ok or bork_via_event bld_node_not_found_event id_str
      end

      def bld_node_not_found_event id_str
        Snag_::Model_::Event.inline :node_not_found, :id_str, id_str do |y, o|
          y << "node lines not found for node with identifier #{ ick id_str }"
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
        ACHIEVED_
      end

      SPACE_RX_ = /^[[:space:]]/

      DEV_NULL_ = Snag_._lib.dev_null
      WRITE_MODE_ = Snag_._lib.writemode

    end
  end
end
