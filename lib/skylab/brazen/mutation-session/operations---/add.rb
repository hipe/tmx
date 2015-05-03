module Skylab::Snag

  module Model_

    class Mutation_Session

      module Operations___

        o = class Add__ < Operation_

          include Collection_Methods_

          self

        end.new :add

        o.operation_category_symbol = :add

        # (modifiers to add as covered: `unless_present`, `via`)

        o.takes_modifier :using

        o.has_non_boolean_result = true

        ADD = o.freeze

      end
    end
  end
end
