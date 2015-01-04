module Skylab::Cull

  class Models_::Survey

    class Actions::Status < Action_

      @after_name_symbol = :edit

      Brazen_.model.entity self,

        :desc, -> y do
          y << "display status of the survey"
        end,

        :description, -> y do
          y << "path from which the survey is searched for"
        end,
        :required, :property, :path

      def produce_any_result

        _ok = via_path_argument_resolve_existent_survey
        _ok and via_survey

      end

      include Survey_Action_Methods_

      def via_survey
        @survey.to_datapoint_stream_for_synopsis
      end

      UNDERSCORE_ = '_'.freeze
    end
  end
end
