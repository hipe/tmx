module Skylab::Cull

  class Models_::Survey

    class Actions::Upstream

      Autoloader_[ ( Actions = ::Module.new ), :boxxy ]

      class Actions::Set < Action_

        Brazen_.model.entity self,

          :required, :property, :path,

          :required, :property, :upstream_identifier

        def produce_any_result
          via_path_argument_resolve_existent_survey and
          via_survey
        end

        include Survey_Action_Methods_

        def via_survey
          @survey.edit do | o |
            o.set_upstream_via_mutable_arg_box to_bound_argument_box
          end
        end
      end
    end
  end
end
