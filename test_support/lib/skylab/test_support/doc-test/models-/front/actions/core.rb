module Skylab::TestSupport

  module DocTest

    class Action_ < Brazen_::Model.common_action_class

      Brazen_::Model.common_entity self do

      end
    end

    module Models_::Front

      module Actions

        Autoloader_[ self, :boxxy ]

      end

      class Actions::Ping < Action_

        edit_entity_class :promote_action

        def produce_result

          maybe_send_event :payload, :ping do

            build_OK_event_with :ping do |y, o|
              y << "ping #{ highlight '!' }"
            end
          end

          :_hello_from_doc_test_
        end
      end
    end
  end
end
