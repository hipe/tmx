module Skylab::Cull

  class Models_::Survey

    class Actions::Status < Action_

      Brazen_.model.entity self,

        :after, :create,

        :desc, -> y do
          y << "display status of the survey"
        end,

        :description, -> y do
          y << "path from which the survey is searched for"
        end,
        :required, :property, :path

      def produce_any_result

        @path = Models_::Survey.any_nearest_path_via_looking_upwards_from_path(
          get_argument_via_property_symbol( :path ),
          & handle_event_selectively )

        @path and via_path
      end

      def via_path
        @ent = Models_::Survey.edit_entity @kernel, handle_event_selectively do | o |
          o.existent_valid_workspace_path @path
        end
        @ent and via_ent
      end

      def via_ent
        @ent.to_datapoint_stream_for_synopsis
      end

      UNDERSCORE_ = '_'.freeze
    end
  end
end
