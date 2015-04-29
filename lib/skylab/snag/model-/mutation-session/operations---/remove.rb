module Skylab::Snag

  module Model_

    class Mutation_Session

      module Operations___

        o = class Remove__ < Operation_

          include Collection_Methods_

          self

        end.new :remove

        o.operation_category_symbol = :remove

        o.takes_modifier :is_flag, :if_present

        o.takes_modifier :via

        o.has_non_boolean_result = true

        REMOVE = o.freeze

        class Remove__

          def if_present=

            @do_check_for_redundancy_ = true
            NIL_
          end

          def when_the_operation_succeeded_ ok_x

            @on_event_selectively.call :info, :entity_removed do

              event_class_( :entity_removed ).new_with(
                :entity, ok_x,
                :entity_collection, @subject_component )
            end

            super
          end
        end
      end
    end
  end
end
