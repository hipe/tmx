module Skylab::Snag

  class Models_::To_Do

    module Actors_::Matching_line_stream_via_find_command
      # <-
    define_singleton_method :[] do | cmd,  system_conduit, & x_p |

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
              p = EMPTY_P_
              When_error_line___[ line_s, e, & x_p ]
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
    # ->

      When_error_line___ = -> line, e, & x_p do

        x_p.call :error, :expression, :sytem_call_error do | y |
          y << line
        end

        UNABLE_
      end
    end
  end
end
