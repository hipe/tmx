module Skylab::CodeMetrics

    class Magnetics_::Line_Upstream_via_System_Command

      def initialize & p
        @listener = p
      end

      attr_writer(
        :system_conduit,
        :system_command_string_array,
      )

      def execute

        _, o, e, w = @system_conduit.popen3( * @system_command_string_array )

        s = o.gets
        if s
          __stdout_line_stream_via_one_good_string s, o, e, w
        elsif
          s = e.gets
          if s
            self._SQUAWK
          elsif w.value.exitstatus.zero?
            Common_::THE_EMPTY_STREAM
          else
            self._SQUAWK
          end
        end
      end

      def __stdout_line_stream_via_one_good_string s, o, e, w

        p = nil

        normal_p = -> do
          s = o.gets
          if s
            s
          else
            s = e.gets
            if s
              self._SQUAWK
            else
              d = w.value.exitstatus
              if d.zero?
                p = EMPTY_P_
                NIL_
              else
                self._SQUAWK
              end
            end
          end
        end

        p = -> do
          p = normal_p
          s
        end

        Common_.stream do
          p[]
        end
      end
    end
  # -
end
