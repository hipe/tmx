module Skylab::Snag

  module Model_

    class Mutation_Session

      module Operations___

        o = class Set__ < Operation_

          self

        end.new :set

        o.takes_modifier :via

        SET = o.freeze

        class Set__

          def via= x  # :+#cp

            @via_ = x
            NIL_
          end

          def via_components_execute

            # (the not-using-a-mutable-body way:)

            ok = @subject_component.send(
              :"receive__#{ @association_symbol }__for_mutation_session",
              @object_component_x,
              & @on_event_selectively )

            @full_execution_result_x = ok
            if ok
              @change_did_occur = true  # we assume ..
            end

            ok
          end
        end
      end
    end
  end
end
