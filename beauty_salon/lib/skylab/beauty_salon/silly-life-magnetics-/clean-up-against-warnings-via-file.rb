module Skylab::BeautySalon

  class SillyLifeMagnetics_::CleanUpAgainstWarnings_via_File < Common_::MagneticBySimpleModel

    # the essential objective of this magnet is to serve its sole client,
    # which explains in detail its behavior and purpose. (caveat: it's a
    # bit of a band-aid; it might not be around for long.)
    #
    # however, this work exists here in this dedicated magnet because
    # it's generic enough to be useful elsewhere (potentially).

    # -

      attr_writer(
        :listener,
        :input_file,
      )
    # -

      def execute

        if __first_thing
          __second_thing
        end
      end

      def __second_thing

        _sess = Home_.lib_.system_lib::Filesystem::TmpfileSessioner.define do |o|

          require 'tmpdir'
          o.tmpdir_path ::Dir.tmpdir

          o.using_filesystem ::File
        end

        _yikes = _sess.session do |tmpfile_IO|
          __each_replacement_line do |line|
            tmpfile_IO.write line
          end
          tmpfile_IO.path
        end

        _yikes
      end

      def __each_replacement_line

        h = remove_instance_variable :@__unit_of_work_via_line_number
        lines = ::File.open @input_file
        lineno = 0
        begin
          line = lines.gets
          line || break
          lineno += 1
          p = h[ lineno ]
          if p
            replacement_lines = p[ line ]
            if replacement_lines
              replacement_lines.each do |replacement_line|
                yield replacement_line
              end
            else
              yield line
            end
          else
            yield line
          end
          redo
        end while above
        lines.close
        NIL
      end

      def __first_thing

        _ = PendingLineChanges_via_File___.call_by do |o|
          o.input_file = @input_file
          o.listener = @listener
        end

        _store :@__unit_of_work_via_line_number, _
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    # -

    class PendingLineChanges_via_File___ < Common_::MagneticBySimpleModel

      attr_writer(
        :input_file,
        :listener,
      )

      def execute
        _ok = __first_of_all_OMG_capture_the_errput_this_way
        _ok && __the_rest
      end

      def __the_rest
        if __has_any_lines_of_errput
          __parse_each_line
          remove_instance_variable :@_unit_of_work_via_line_number
        else
          __whine_about_no_errput_lines
        end
      end

      def __whine_about_no_errput_lines
        path = @input_file
        @listener.call :expression, :info, :no_errput_lines do |y|
          y << "no warnings in file: #{ path }"
        end
        NOTHING_
      end

      # --

      def __parse_current_line
        md = /\A(?<file>[^ ]+\.rb):(?<lineno>\d+): warning: (?<warning_msg>.+)$/.match @_current_line
        if md
          __process_warning_line md
        else
          __whine_about_unparsable_line
        end
        NIL
      end

      def __process_warning_line md

        __assert_everything_is_same_file md[ :file ]

        case md[ :warning_msg ]
        when /\Amismatched indentations at '(?<begin_item>[^']+)' with '(?<end_item>[^']+)' at (?<lineno>\d+)\z/
          __process_line_about_mismatched_indentation $~, md
        when /\Aassigned but unused variable - (?<variable_name>.+)\z/
          __process_line_about_ununsed_variable $~, md
        else
          self._HOLE__oh_how_fun_a_new_warning__
        end
      end

      # --

      def __process_line_about_mismatched_indentation md_, md

        first_of_two_lineno = md_[ :lineno ].to_i
        second_of_two_lineno = md[ :lineno ].to_i

        # _begin_item = md_[ :begin_item ]
        # _end_item = md_[ :end_item ]

        first_of_two_lineno < second_of_two_lineno or self._SANITY__line_numbers_ordinality__

        # the essential objective here is to make the *indentation* (or
        # if you like "margin") of the two lines be the same substring of
        # characters (probably spaces).
        #
        # now, if the primary optimization category was "aesthethics", this
        # algorithm could be made complicated like so: wait until we
        # traverse the second of the two lines. once we have both real lines,
        # determine which one is (say) more indented. make the other line
        # that way. keep in mind that it might be the earlier of the two
        # lines that needs to be edited.
        #
        # such an approach is potentially a "heavy lift": in a stream-
        # centric way we only traverse the real lines once. it may be the
        # case that once we discover that we need to change the earlier of
        # two lines, we will have already passed it, closing the window of
        # time when we could have changed it.
        #
        # rather than complicate this by making it multi-pass or dismantle
        # the stream-centricity altogether; we discard the premise. instead,
        # we always make the second line accord with the first line.

        ohai = nil
        first_of_two_lines = nil

        rx = /\A[ \t]*/

        other_thing = -> line do

          md = rx.match first_of_two_lines
          _new_line = line.sub rx, md[ 0 ]
          [ _new_line ]
        end

        _on_this_line_do_this first_of_two_lineno do |line|
          first_of_two_lines = line
          ohai = other_thing
          NOTHING_
        end

        _on_this_line_do_this second_of_two_lineno do |line|
          ohai[ line ]
        end
      end

      def __process_line_about_ununsed_variable md_, md

        _lineno = md[ :lineno ].to_i
        var_name = md_[ :variable_name ]

        _on_this_line_do_this _lineno do |line|

          rx = %r(\b#{ ::Regexp.escape var_name }\b)
          pos = 0
          a = []
          begin
            md = rx.match line, pos
            md || break
            a.push md
            pos = md.offset(0).last
            redo
          end while above
          if 1 == a.length
            _new_line = line.sub rx, "_NOT_USED_#{ var_name }"
            [ _new_line ]
          else
            self._COVER_ME__ignore_this_hacky_change_
          end
        end
      end

      def _on_this_line_do_this d, & p
        @_unit_of_work_via_line_number[ d ] && fail
        @_unit_of_work_via_line_number[ d ] = p
      end

      # --

      def __assert_everything_is_same_file file
        send @_assert_everything_is_same_file, file
      end

      def __assert_everything_is_same_file_initially file
        @_assert_everything_is_same_file = :__assert_everything_is_same_file_subsequently
        @_always_same_file = file
      end

      def __assert_everything_is_same_file_subsequently file
        @_always_same_file == file || self._SANITY__we_need_logic_for_this__
      end

      # --

      def __whine_about_unparsable_line
        line = @_current_line
        @listener.call :expression, :la_la do |y|
          y << "skipping this line: #{ line }"
        end
        NIL
      end

      def __parse_each_line
        line = remove_instance_variable :@__first_line_of_errput
        st = remove_instance_variable :@__errput_line_upstream
        begin
          @_current_line = line
          __parse_current_line
          line = st.gets
        end while line
        ACHIEVED_
      end

      def __has_any_lines_of_errput

        _s = remove_instance_variable :@__errput_lines_big_string
        st = Basic_[]::String::LineStream_via_String[ _s ]
        line = st.gets
        if line
          @__first_line_of_errput = line ; @__errput_line_upstream = st ; ACHIEVED_
        end
      end

      def __first_of_all_OMG_capture_the_errput_this_way

        # :#reason1.1: there's at least 3 ways (maybe) that we can imagine
        # programmatically capturing the warnings generated by the generated
        # file:
        #
        #   1) as we do below
        #
        #   2) in a separate process, load the file with `ruby -wc` and
        #      do output and errput capturing yadda
        #
        #   3) see if there's some lower-level hooks we can hook into our
        #      own ruby runtime more approrpriate for this than the mess we
        #      do below.
        #
        # we go with the simplest aproach (1) because longterm we would like
        # to contribute to ragel such that none of this is necessary (#open [#020])
        #

        __init_some_other_stuff
        require 'stringio'
        recording = ::StringIO.new
        real = $stderr
        $stderr = recording
        begin
          ok = load @input_file
        rescue ::SyntaxError, ::LoadError => e
          NOTHING_
        ensure
          $stderr = real
        end

        if ok
          @__errput_lines_big_string = recording.string
          ACHIEVED_
        else
          real.puts e.message
          recording.rewind
          while line=recording.gets
            real.puts line
          end
          UNABLE_
        end
      end

      def __init_some_other_stuff
        @_assert_everything_is_same_file = :__assert_everything_is_same_file_initially
        @_unit_of_work_via_line_number = {}
      end
    end

    # ==

    # ==
    # ==
  end
end
# #born.
