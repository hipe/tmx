module Skylab::TanMan

  class Models_::Workspace

    module Hear_Map

      module Definitions

        class Init

          def after
            [ :meaning, :set_meaning ]
          end

          def definition
            [ :sequence, :functions,
                :keyword, 'start',
                :keyword, 'a',
                :keyword, 'new',
                :one_or_more, :any_token ]
          end

          def bound_call_via_heard hrd, & oes_p

            self._DO_ME_fun_fix_grammar

            hrd.kernel.bound_API_call_with :init,
              :path, ::Dir.pwd, & oes_p
          end
        end
      end
    end
  end
end
