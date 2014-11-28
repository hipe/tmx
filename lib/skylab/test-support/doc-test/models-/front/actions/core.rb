module Skylab::TestSupport

  module DocTest

    class Action_ < Bzn_.model.action_class

      Bzn_.model_entity self do

      end
    end

    module Models_::Front

      Actions = ::Module.new

      class Actions::Ping < Action_

        o do
          o :is_promoted
        end

        def produce_any_result

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
