module Skylab::TanMan

  class Models_::Association

    module Hear_Map

      module Definitions

        class Touch_Nodes_And_Create_Association

          def after
            # nothing.
          end

          def definition
            [ :sequence, :functions,
                :one_or_more, :any_token,
                :keyword, 'depends',
                :keyword, 'on',
                :one_or_more, :any_token ]
          end

          def bound_call_via_heard hrd
            self._DO_ME
          end
        end

        class Delete_Association

          def after
            [ :meaning, :create_association ]
          end

          def definition
            [ :sequence, :functions,
                :one_or_more, :any_token,
                :keyword, 'does',
                :keyword, 'not',
                :keyword, 'depend',
                :keyword, 'on',
                :one_or_more, :any_token ]
          end

          def bound_call_via_heard hrd
            self._DO_ME
          end
        end
      end
    end
  end
end
# ( a note for #!posterity, the old treemap versions of some of these definitions were in what is now models-/hear-front/core.rb )
