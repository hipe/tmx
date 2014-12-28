module Skylab::Cull

  class Models_::Survey

    class Actions::Upstream

      class Actions::Unset < Action_

        Brazen_.model.entity self,

          :required, :property, :path

        def produce_any_result
          via_path_argument_resolve_existent_survey and via_survey
        end

        include Survey_Action_Methods_

        def via_survey
          @survey.edit do | o |
            o.delete_upstream
          end
        end
      end
    end
  end
end
