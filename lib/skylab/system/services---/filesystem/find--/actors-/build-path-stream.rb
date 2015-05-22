module Skylab::System

  class Services___::Filesystem

    # <-

  class Find__

    class Build_path_stream__

      Callback_::Actor.call self, :properties, :args

      # try to read from the process's STDOUT *first* before seeing if
      # there's STDERR to read. if you read from STDERR it might block
      # if it hasn't yet closed the other stream.

      def execute

        thread = nil

        p = -> do

          _, o, e, thread = System_.lib_.open3.popen3( * @args )

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

        o = Callback_::Stream
        o.new(
          o::Release_Resource_Proxy.new do
            if thread && thread.alive?
              thread.exit
            end
            ACHIEVED_
          end
        ) do
          p[]
        end
      end

      def maybe_send_error_via_find_error_string error_s

        @on_event_selectively.call :error, :find_error do

          Callback_::Event.inline_not_OK_with :find_error, :message, error_s
        end
        nil
      end
    end
  end
# ->
  end
end
