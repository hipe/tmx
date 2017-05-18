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

        if __resolve_existent_survey
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

      # ~( abstraction candidate

      def __resolve_existent_survey

        if __resolve_survey_path_via_path
          __resolve_survey_via_survey_path
        end
      end

      def __resolve_survey_via_survey_path

        # (parse the config file)

        _su_path = remove_instance_variable :@__survey_path
        _ = Here_::Magnetics_::Survey_via_SurveyPath[ _su_path, & _listener_ ]
        _store_ :@_survey_, _
      end

      def __resolve_survey_path_via_path

        # (walk up from the argument path looking for the special filename)

        _ = Here_::Magnetics_::SurveyPath_via_Path[ @path, & _listener_ ]
        _store_ :@__survey_path, _
      end

      # ~)

      # ==
      # ==
    end
  end
end
