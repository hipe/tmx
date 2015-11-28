module Skylab::Cull

  class Models_::Survey

    class Actions::Edit < Action_

      @after_name_symbol = :ping

      Common_entity_.call self,

        :flag, :property, :dry_run,

        :reuse, COMMON_PROPERTIES_,

        :description, -> y do
          y << "edit an existing survey at this path"
        end,
        :required, :property, :path

      include Survey_Action_Methods_

      def produce_result

        @survey = @parent_node.edit do | edit |

          edit.edit_via_mutable_qualified_knownness_box_and_look_path(
            to_qualified_knownness_box_proxy,
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
