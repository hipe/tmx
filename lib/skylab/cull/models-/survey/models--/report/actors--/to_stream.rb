module Skylab::Cull

  class Models_::Survey

    class Models__::Report

      Actors__ = ::Module.new

      class Actors__::To_stream

        Callback_::Actor.call self, :properties,

          :entity_stream, :call_a

        def execute

          mutator_call_a = @call_a  # LOOK
          entity_st = @entity_stream
          oes_p = @on_event_selectively

          Callback_.stream do

            begin

              ent = entity_st.gets
              ent or break

              mutator_call_a.each do | args, function_class |
                function_class[ ent, * args, & oes_p ]
              end

            end while nil

            ent
          end
        end
      end
    end
  end
end
