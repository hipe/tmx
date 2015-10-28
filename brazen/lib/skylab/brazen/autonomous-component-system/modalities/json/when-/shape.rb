module Skylab::Brazen

  module Autonomous_Component_System

    module Modalities::JSON::When_

      Shape = Callback_::Event.prototype_with(

        :bad_shape,
        :x, nil,
        :context_string_proc_stack, nil,
        :error_category, :type_error,
        :ok, false,

      ) do | y, o |

        tightest_context, trailing_context = Express_context_under_[
          o.context_string_proc_stack, self, 'for' ]

        y << "#{ tightest_context }#{
          }expected hash, had #{ ick o.x }#{
           }#{ trailing_context }"
      end

      def Shape.[] x, sess

        # (overrides a an event prototype method for building an event)

        sess.on_event_selectively.call :error, :strange_shape do

          new_with(
            :x, x,
            :context_string_proc_stack, sess.context_string_proc_stack,
          )
        end
        UNABLE_
      end
    end
  end
end
