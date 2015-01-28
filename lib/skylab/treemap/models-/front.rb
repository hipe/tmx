module Skylab::Treemap

  module Models_

    class Front

      module Actions

        class Ping < Brazen_.model.action_class

          @is_promoted = true

          def produce_result
            maybe_send_event :info, :ping do
              build_neutral_event_with :ping do | y, o |
                y << "hello from #{ app_name }."
              end
            end
            :hello_from_treemap
          end
        end
      end
    end
  end
end
