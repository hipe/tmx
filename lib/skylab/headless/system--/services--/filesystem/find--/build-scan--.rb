module Skylab::Headless

  module System__

    class Services__::Filesystem

  class Find__

    class Build_scan__

      Callback_::Actor.call self, :properties,

        :on_event_selectively, :valid_command_s

      def execute
        p = -> do
          _, sout, serr = Headless_::Library_::Open3.popen3 @valid_command_s
          error_s = serr.read
          if error_s.length.zero?
            p = -> do
              x = sout.gets
              if x
                x.chomp!
                x  # :+#experimental
              else
                p  = EMPTY_P_
              end
              x
            end
            p.call
          else
            maybe_send_error_via_find_error_string error_s
            p = -> { UNABLE_ }
            UNABLE_
          end
        end
        Callback_.scan do
          p[]
        end
      end

      def maybe_send_error_via_find_error_string error_s

        @on_event_selectively.call :error, :find_error do

          Headless_::Lib_::Event_lib[].inline_with :find_error,
            :message, error_s, :ok, false
        end
        nil
      end
    end
  end

    end
  end
end
