module Skylab::Cull

  class Models_::Survey

    class Actions::Create

      def initialize
        extend SurveyActionMethods_
        init_action_ yield
      end

      # #was-promoted, #was-after: ping

      def definition ; [

        :flag, :property, :dry_run,

        :properties, these_common_associations_,

        :description, -> y do
          y << "create a cull survey workspace directory in the path"
        end,
        :required, :property, :path,

      ] end

      def execute

        ok = true
        __init_empty_survey
        ok &&= __persist_survey_via_survey
        ok && __emit_survey_as_result
      end

      def __emit_survey_as_result
        _ev = @_survey_.to_event
        _em = Common_::Emission.of :info, :created_survey do
          _ev
        end
        _em  # #todo hi.
      end

      def __persist_survey_via_survey
        _ = Here_::Magnetics_::CreateSurvey_via_Survey.call(
          @_survey_, self, & _listener_ )
        _
      end

      def __init_empty_survey

        @_survey_ = Here_.define_sanitized_ do |o|

          o.init_for_create__
          o.path = @path
        end
        NIL
      end

      # ==
      # ==
    end
  end
end
