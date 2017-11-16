module Skylab::System

  class Find

    class PathStream_via_SystemCommand___ < Common_::Dyadic

      def initialize x, sc, & p
        @args = x
        @system_conduit = sc
        @listener = p
      end

      # try to read from the process's STDOUT *first* before seeing if
      # there's STDERR to read. if you read from STDERR it might block
      # if it hasn't yet closed the other stream.

      def execute

        thread = nil

        p = -> do

          _, o, e, thread = @system_conduit.popen3( * @args )

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

        Common_::Stream.define do |o|
          o.upstream_as_resource_releaser_by do
            if thread && thread.alive?
              thread.exit
            end
            ACHIEVED_
          end
          o.stream_by do
            p[]
          end
        end
      end

      def maybe_send_error_via_find_error_string error_s

        @listener.call :error, :find_error do

          Common_::Event.inline_not_OK_with :find_error, :message, error_s do |y, o|

            # see tombstone - we used to let the default inline event
            # expression happen, but it was truncating the long strings from
            # `find`, strings which have useful content in them talking bout
            # noent paths. also, that behavior would contextualize this with
            # "find error: " but that is mostly redundant with what `find`
            # itself emits.

            y << o.message
          end
        end
        nil
      end
    end
  end
end
# #tombstone: we used to let the defalt inline event expression happen
