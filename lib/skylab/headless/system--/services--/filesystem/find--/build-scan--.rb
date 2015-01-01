module Skylab::Headless

  module System__

    class Services__::Filesystem

  class Find__

    class Build_scan__

      Callback_::Actor.call self, :properties,

        :on_event_selectively, :valid_command_s

      # try to read from the process's STDOUT *first* before seeing if
      # there's # STDERR to read. if you read from STDERR it might block
      # if it hasn't yet closed the other stream.

      def execute
        thread = nil
        p = -> do
          _, o, e, thread = Headless_::Library_::Open3.popen3 @valid_command_s
          p = -> do
            s = o.gets
            if s  # then no error on first try
              s.chomp!  # :+#experimental
              s
            else
              s_ = e.gets
              while s_
                s_.chomp!
                maybe_send_error_via_find_error_string s_
                result = UNABLE_
                s_ = e.gets
              end
              p = -> { result }
              result
            end
          end
          p[]
        end

        Callback_.scan do
          p[]
        end.with_signal_handlers :release_resource, -> do
          if thread && thread.alive?
            thread.exit
          end
          ACHIEVED_
        end
      end

      def maybe_send_error_via_find_error_string error_s

        @on_event_selectively.call :error, :find_error do

          Headless_.lib_.event_lib.inline_with :find_error,
            :message, error_s, :ok, false
        end
        nil
      end
    end
  end
    end
  end
end
