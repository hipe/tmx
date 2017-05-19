module Skylab::Cull

  class Models_::Survey

    class Actions::Status

      def initialize
        extend SurveyActionMethods_
        init_action_ yield
      end

      # #was-after: edit

      def definition ; [

        :description, -> y do
          y << "display status of the survey"
        end,

        :required, :property, :path,
        :description, -> y do
          y << "path from which the survey is searched for"
        end,

      ] end

      def execute

        if resolve_existent_survey_via_path_
          __via_survey
        end
      end

      def __via_survey

        # (was `to_datapoint_stream_for_synopsis`)

        _st = @_survey_.config_for_read_.to_section_stream
        _st.map_by do |sect|
          Here_::Models__::SectionSummary.new sect
        end
      end

      # ==
      # ==
    end
  end
end
