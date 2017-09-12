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
        _ = @_survey_.persist_by_ do |o|
          o.is_dry_run = @dry_run
          o.filesystem = _filesystem_
          o.listener = _listener_
        end
        _
      end

      def __init_empty_survey

        _survey_path = ::File.join @path, FILENAME_

        _config = Git_config_[]::Mutable.new_empty_document

        @_survey_ = Here_.define_survey_ do |o|

          o.accept_initial_config_ _config
          o.survey_path = _survey_path
        end
        NIL
      end

      Actions = nil

      # ==
      # ==
    end
  end
end
