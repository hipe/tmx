module Skylab::Snag

  class Models_::To_Do

    Actors_::Matching_line_stream_via_find_command = -> cmd, system_conduit, & x_p do

      p = -> do

        fly = nil

        reinitialize_flyweight = -> line_s do

          fly = To_Do_::Models_::Matched_Line.new line_s

          reinitialize_flyweight = -> line_s_ do
            fly.reinitialize line_s_
            NIL_
          end

          NIL_
        end

        _i, o, e, t = system_conduit.popen3( * cmd.args )

        p = -> do

          line_s = o.gets
          if line_s
            reinitialize_flyweight[ line_s ]
            fly
          else
            line_s = e.gets
            if line_s
              t.terminate
              self._TODO__receive_error_line line_s
              p = EMPTY_P_
              NIL_
            else
              p = EMPTY_P_
              NIL_
            end
          end
        end

        p[]
      end

      Callback_.stream do
        p[]
      end
    end
  end
end
