module Skylab::System

  class Doubles::Stubbed_System::Recording

    class CacheBasedExpressionEngine___

      # if your application under test uses more than one open process at
      # a time (as ours did, when it took the results of an (imagine long-
      # running) process line by line (a `git log` command), and fed each
      # line into something that created another process (imagine a shorter
      # one, a `git show` command)); in such cases we can't use the simple
      # stream-based recording engine because there isn't a clean beginning
      # and endingpoint between the different processes. so we cache *all*
      # the througput lines into *memory* and then only render the fixture
      # structure at the end. more discussion (and alternatives) in [#036].

      def initialize ren, real_sys
        @line_limit = 100  # don't assume you have infinite memory resources
        @_process_recordings = nil
        @real_system = real_sys
        @rendering = ren
      end

      def receive_first_popen3_ argv
        @_check = method :__check_and_increment_line_count
        @_number_of_lines_stored = 0
        @_process_recordings = []
        _same argv
      end

      def receive_subsequent_popen3_ argv
        _same argv
      end

      def _same argv
        _d = @_process_recordings.length
        rec = ProcessRecording___.new argv, @_check, @rendering, @real_system
        @_process_recordings[ _d ] = rec
        rec.to_four
      end

      def __check_and_increment_line_count
        if @line_limit == @_number_of_lines_stored
          self.__REACHED_HARDCODED_LIMIT_of_the_number_of_lines_allowed_to_be_cached_in_memory
        else
          @_number_of_lines_stored += 1
        end
        NIL
      end

      def receive_done_
        a = remove_instance_variable :@_process_recordings
        if a
          __do_render a
        else
          @rendering.indented_puts "# received no calls to `popen3`"
        end
        NIL
      end

      def __do_render a
        @rendering.express_the_opening
        st = Stream_[ a ]
        rec = st.gets
        begin
          @rendering.express_blank_line
          rec.receive_done
          rec = st.gets
          rec ? redo : break
        end while above
        @rendering.receive_done
        NIL
      end

      # ==

      class ProcessRecording___

        def initialize argv, check, ren, sys

          _err = ReadStreamProxy_.new method :__receive_err_gets
          _out = ReadStreamProxy_.new method :__receive_out_gets
          _wai = WaitProxy_.new method :__receive_exitstatus_read

          @_receive_err_gets = :__receive_first_err_gets
          @_receive_out_gets = :__receive_first_out_gets
          @_receive_exitstatus_read = :_receive_only_exitstatus_read

          @__argv = argv  # needed for rendering, which happens later
          @_check_number_of_lines = check
          @_did_read_exitstatus = false
          @_has_err_lines = false
          @_has_out_lines = false
          @rendering = ren

          _ignore_sin_, @out, @err, @wait = sys.popen3( * argv )

          @__to_four = [ :_dont_sin_, _out, _err, _wai ]
        end

        def to_four
          remove_instance_variable :@__to_four
        end

        def __receive_out_gets
          send @_receive_out_gets
        end

        def __receive_err_gets
          send @_receive_err_gets
        end

        def __receive_exitstatus_read
          send @_receive_exitstatus_read
        end

        def __receive_first_out_gets
          _receive_first_gets :out
        end

        def __receive_first_err_gets
          _receive_first_gets :err
        end

        def __receive_subsequent_out_gets
          _receive_subsequent_gets :out
        end

        def __receive_subsequent_err_gets
          _receive_subsequent_gets :err
        end

        def _receive_first_gets key

          o = IVARS_ETC__.fetch key

          line = instance_variable_get( o.stream_ivar ).gets
          if line
            @_check_number_of_lines.call
            instance_variable_set o.method_ivar, o.subsequent_method
            instance_variable_set o.array_ivar, [ line ]
            instance_variable_set o.has_ivar, true
          else
            instance_variable_set o.method_ivar, :__CLOSED
          end
          line
        end

        def _receive_subsequent_gets key

          o = IVARS_ETC__.fetch key

          line = instance_variable_get( o.stream_ivar ).gets
          if line
            @_check_number_of_lines.call
            instance_variable_get( o.array_ivar ).push line
          else
            instance_variable_set o.method_ivar, :__CLOSED
          end
          line
        end

        IvarsEtc__ = ::Struct.new(
          :array_ivar,
          :has_ivar,
          :method_ivar,
          :stream_ivar,
          :subsequent_method,
        )

        h = {}

        o = IvarsEtc__.new
        o.array_ivar = :@_err_lines
        o.has_ivar = :@_has_err_lines
        o.method_ivar = :@_receive_err_gets
        o.stream_ivar = :@err
        o.subsequent_method = :__receive_subsequent_err_gets
        h[ :err ] = o

        o = IvarsEtc__.new
        o.array_ivar = :@_out_lines
        o.has_ivar = :@_has_out_lines
        o.method_ivar = :@_receive_out_gets
        o.stream_ivar = :@out
        o.subsequent_method = :__receive_subsequent_out_gets
        h[ :out ] = o

        IVARS_ETC__ = h

        def receive_done

          if ! @_did_read_exitstatus
            # (this is kind of nasty - the client didn't "finish" but we
            # are going to, to make the process be complete in its fixture?)
            _receive_only_exitstatus_read
          end

          @rendering.express_process_opening remove_instance_variable :@__argv

          d = remove_instance_variable :@__exitstatus
          o = @rendering.new_process_rendering

          if @_has_out_lines
            _ = remove_instance_variable :@_out_lines
            o.express_all_nonzero_lines _, :out
          end

          if @_has_err_lines
            _ = remove_instance_variable :@_err_lines
            o.express_all_nonzero_lines _, :err
          end

          o.close d
          NIL
        end

        def _receive_only_exitstatus_read
          _real_wait = remove_instance_variable :@wait
          d = _real_wait.value.exitstatus
          @__exitstatus = d
          @_did_read_exitstatus = true
          d
        end
      end

      # ==

      # ==
    end
  end
end
# #history: born.
