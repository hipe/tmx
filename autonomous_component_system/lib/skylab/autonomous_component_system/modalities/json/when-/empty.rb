module Skylab::Autonomous_Component_System

  # ->

    module Modalities::JSON::When_

      Empty = Common_::Event.prototype_with(

        :empty_object,
        :context_linked_list, nil,
        :ok, false,

      ) do | y, o |

        leading, trailing = Express_context_under_[ o.context_linked_list, self, 'for' ]

        if ! trailing
          leading.strip!
        end

        y << "for now, will not parse empty JSON object #{
          }#{ leading }#{
           }#{ trailing }"
      end

      def Empty.[] sess

        sess.caller_emission_handler_.call :error, :empty_object do

          with :context_linked_list, sess.context_linked_list
        end

        UNABLE_  # important
      end
    end
  # -
end
