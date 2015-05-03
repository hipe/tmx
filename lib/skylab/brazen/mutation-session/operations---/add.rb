module Skylab::Brazen

  # ->

    class Mutation_Session

      module Operations___

        o = class Add__ < Operation_

          include Collection_Methods_

          self

        end.new :add

        o.operation_category_symbol = :add

        o.takes_modifier :is_flag, :unless_present

        o.takes_modifier :using

        o.takes_modifier :via

        o.has_non_boolean_result = true

        ADD = o.freeze

      end
    end
    # <-
end
