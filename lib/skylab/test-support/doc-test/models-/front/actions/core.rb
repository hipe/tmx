module Skylab::TestSupport

  module DocTest

    class Action_ < Brazen_.model.action_class

      Brazen_.model.entity self do

      end
    end

    module Models_::Front

      module Actions

        Autoloader_[ self, :boxxy ]

        class << self
          def constants( * )
            @constants ||= begin  # remove this selfsame file from the list :/
              a = super
              d = a.index :Core
              a[ d ] = nil
              a.compact!
              a
            end
          end
        end
      end

      class Actions::Ping < Action_

        edit_entity_class do
          o :promote_action
        end

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
