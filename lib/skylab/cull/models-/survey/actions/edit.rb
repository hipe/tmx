module Skylab::Cull

  class Models_::Survey

    class Actions::Edit < Action_

      Brazen_.model.entity self,

        :flag, :property, :dry_run,

        :reuse, Survey_Action_Methods_.common_properties,

        :description, -> y do
          y << "edit an existing survey at this path"
        end,
        :required, :property, :path

      include Survey_Action_Methods_

      def produce_any_result

        @survey = @parent_node.edit do | edit |

          edit.edit_via_mutable_arg_box_and_look_path(
            to_bound_argument_box,
            @argument_box.fetch( :path ) )

        end

        @survey and via_survey
      end

      def via_survey
        @survey.re_persist @argument_box[ :dry_run ]
      end
    end
  end
end
