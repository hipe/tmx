module Skylab::Brazen

  # ->

    class Autonomous_Component_System::Mutation_Session

      module Operations___

        o = class Append__ < Operation_

          include Collection_Methods_

          self

        end.new :append

        o.operation_category_symbol = :add

        o.takes_modifier :is_flag, :unless_present

        o.takes_modifier :via

        o.has_non_boolean_result = true

        APPEND = o.freeze

      end
    end
    # <-
end
