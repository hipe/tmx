module Skylab::Cull

  class Models_::Survey

    class Actions::Reduce < Action_

      @after_name_symbol = :edit

      _prp = Models_::Upstream::Actions::Map::TABLE_NUMBER_PROPERTY.
        new_without_default

      Brazen_::Model.common_entity self,

        :reuse, COMMON_PROPERTIES_,

        :property_object, _prp,

        :description, -> y do
          y << "if provided, this survey will be used as a startingpoint."
        end,
        :property, :path

      include Survey_Action_Methods_

      def produce_result

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

          edit.edit_via_mutable_trio_box_and_look_path(
            to_trio_box_proxy,
            path )

        end

        @survey ? ACHIEVED_ : UNABLE_
      end

      def resolve_transient_survey

        @survey = @parent_node.edit do  | edit |
          edit.edit_via_mutable_trio_box to_trio_box_proxy
        end

        @survey ? ACHIEVED_ : UNABLE_
      end

      def via_survey

        upstream = @survey.touch_associated_entity_ :upstream

        times_d = @argument_box[ :table_number ]

        estream = if times_d
          upstream.entity_stream_at_some_table_number times_d
        else
          upstream.to_entity_stream
        end

        if estream
          _x = @survey.touch_associated_entity_ :report  # for now
          _x.against estream
        else
          estream
        end
      end
    end
  end
end
