module Skylab::System

  class Doubles::Stubbed_System::Recording

    class StreamBasedExpressionEngine___

      # the stream-based expression engine was the first one. the experiment
      # was "can we keep things simple and scalable by outputting lines one-
      # for one from the real system process as fixture file lines?" and the
      # answer was "yes, but only for our first use case." the idea of
      # "expression engines" didn't come about until we needed the caching
      # expression engine for use casese where there are multiple open
      # processes..

      def initialize ren, real_sys
        @real_system = real_sys
        @rendering = ren
      end

      def receive_first_popen3_ argv
        @rendering.express_the_opening
        _receive_popen3 argv
      end

      def receive_subsequent_popen3_ argv
        _receive_popen3 argv
      end

      def _receive_popen3 argv

        @rendering.express_blank_line
        @rendering.indented_puts "o.on #{ argv.inspect } do"

        sin, out, err, wait = @real_system.popen3( * argv )

        ProcessRecording___.new( sin, out, err, wait, argv, @rendering ).to_four
      end

      def receive_done_
        @rendering.receive_done__
        NIL
      end

      # ==

      class ProcessRecording___

        def initialize psin, psout, pserr, wait, argv, rendering

          @argv = argv
          @pserr = pserr
          @psout = psout
          @rendering = rendering
          @wait = wait

          @_receive_exitstatus = :__CANNOT_receive_exitstatus_because_waiting_for_both_streams_to_close
          @_receive_serr = :__receive_first_which_is_serr
          @_receive_sout = :__receive_first_which_is_sout
        end

        def to_four

          serr_proxy = ReadStreamProxy_.new method :__on_serr_gets
          sout_proxy = ReadStreamProxy_.new method :__on_sout_gets
          wait_proxy = WaitProxy_.new method :__on_request_exitstatus

          [ NOTHING_, sout_proxy, serr_proxy, wait_proxy ]
        end

        def __on_serr_gets
          line = @pserr.gets
          send @_receive_serr, line
          line
        end

        def __on_sout_gets
          line = @psout.gets
          send @_receive_sout, line
          line
        end

        def __on_request_exitstatus
          d = @wait.value.exitstatus
          send @_receive_exitstatus, d
          d
        end

        def __receive_first_which_is_serr line
          _on_first_first line, :err, :out, :@_receive_serr, :@_receive_sout
        end

        def __receive_first_which_is_sout line
          _on_first_first line, :out, :err, :@_receive_sout, :@_receive_serr
        end

        def _on_first_first line, stem, stem_, ivar, ivar_
          @_second_stem = stem_
          @_first_ivar = ivar
          @_second_ivar = ivar_

          @_process_rendering = @rendering.new_process_rendering

          @_process_rendering.express_any_first_line stem, line

          if line
            instance_variable_set ivar, :_on_subsequent_first
            instance_variable_set ivar_, :__CANT_because_other_stream_is_active
          else
            _on_close_of_first_stream
          end
          NIL
        end

        def __mode_change line

          @_process_rendering.express_any_first_line @_second_stem, line
          if line
            instance_variable_set @_second_ivar, :_on_subsequent_second
          else
            __on_close_of_second_stream
          end
          NIL
        end

        def _on_subsequent_first line
          if line
            @_process_rendering.express_line line
          else
            @_process_rendering.receive_an_end_of_lines
            _on_close_of_first_stream
          end
          NIL
        end

        def _on_subsequent_second line
          if line
            @_process_rendering.express_line line
          else
            @_process_rendering.receive_an_end_of_lines
            _on_close_of_second_stream
          end
        end

        def _on_close_of_first_stream
          instance_variable_set @_first_ivar, :__CLOSED
          instance_variable_set @_second_ivar, :__mode_change
        end

        def __on_close_of_second_stream
          instance_variable_set @_second_ivar, :__CLOSED
          @_receive_exitstatus = :__receive_only_exitstatus
        end

        def __receive_only_exitstatus d
          @_receive_exitstatus = :__CANNOT_receive_exitstatus_again
          @_process_rendering.close d
          NIL
        end
      end

      # ==
    end
  end
end
# #history: abstracted from local core node.
