module Skylab::Cull

  class Models_::Survey

    class Actions::Reduce < Action_

      @after_name_symbol = :edit

      Brazen_.model.entity self,

        :reuse, Survey_Action_Methods_.common_properties,

        :reuse, [ Models_::Upstream::Actions::Map::TABLE_NUMBER_PROPERTY ],

        :description, -> y do
          y << "if provided, this survey will be used as a startingpoint."
        end,
        :property, :path

      include Survey_Action_Methods_

      def produce_any_result

        path = @argument_box[ :path ]

        _ok = if path
          resolve_edited_survey_via_path path
        else
          resolve_transient_survey
        end

        _ok and via_survey
      end

      def resolve_edited_survey_via_path path

        @survey = @parent_node.edit do | edit |

          edit.edit_via_mutable_arg_box_and_look_path(
            to_bound_argument_box,
            path )

        end

        @survey ? ACHIEVED_ : UNABLE_
      end

      def resolve_transient_survey

        @survey = @parent_node.edit do  | edit |
          edit.edit_via_mutable_arg_box to_bound_argument_box
        end

        @survey ? ACHIEVED_ : UNABLE_
      end

      def via_survey

        st_st = @survey.existent_associated_entity_( :upstream ).  # for now
          to_entity_collection_stream

        st = nil
        @argument_box[ :table_number ].times do
          st = st_st.gets
        end

        @survey.existent_associated_entity_( :report ). # for now
          against( st )

      end
    end
  end
end
