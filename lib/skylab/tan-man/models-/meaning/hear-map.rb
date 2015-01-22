module Skylab::TanMan

  class Models_::Meaning

    module Hear_Map

      module Definitions

        class Set_Meaning

          def after
            [ :meaning, :delete_meaning ]
          end

          def definition
            [ :sequence, :functions,
                :one_or_more, :any_token,
                :keyword, 'means',
                :one_or_more, :any_token ]
          end

          def bound_call_via_heard hrd, & oes_p

            pt, bx, k = hrd.to_a

            k.bound_API_call_with :meaning, :add,
              :name, pt.fetch( 0 ).join( SPACE_ ),
              :value, pt.fetch( 2 ).join( SPACE_ ),
              :force,  # because this is "set" not "create"
              :workspace_path, bx[ :workspace_path ],
              :config_filename, bx[ :config_filename ],
              & oes_p
          end
        end

        class Delete_Meaning

          def after
            [ :association, :delete_association ]
          end

          def definition
            [ :sequence, :functions,
                :keyword, 'forget',
                :one_or_more, :any_token ]
          end

          def bound_call_via_heard pt
            self._DO_ME
          end
        end

        class Create_Association

          def after
            [ :meaning, :delete_association ]
          end

          def definition
            [ :sequence, :functions,
                :one_or_more, :any_token,
                :keyword, 'is',
                :one_or_more, :any_token ]

          end

          def bound_call_via_heard hrd
            self._DO_ME
          end
        end

        class Delete_Association

          def after
            [ :association, :touch_nodes_and_create_association ]
          end

          def definition
            [ :sequence, :functions,
                :one_or_more, :any_token,
                :keyword, 'is',
                :keyword, 'not',
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
