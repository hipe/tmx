module Skylab::Cull

  class Models_::Survey

    class Actions::Edit

      def initialize
        @table_number = nil  # not settable. #thing-x
        extend SurveyActionMethods_
        init_action_ yield
      end

      # #was-after: ping

      def definition ; [

        :flag, :property, :dry_run,

        :properties, these_common_associations_,

        :required, :property, :path,
        :description, -> y do
          y << "edit an existing survey at this path"
        end,
      ] end

      def execute
        ok = resolve_existent_survey_via_path_
        ok &&= __edit_survey
        ok &&= __persist_survey
        ok || NIL_AS_FAILURE_
      end

      def __edit_survey

        _ok = PersistenceToolkit_[]::EditComponents_via_Request_and_MutableEntity.call_by do |o|
          o.parameter_value_store = self
          o.mutable_entity = @_survey_
          o.listener = _listener_
        end

        _ok  # hi. #todo
      end

      def __persist_survey
        @_survey_.persist_by_ do |o|
          o.is_re_persist = true
          o.is_dry_run = @dry_run
          o.filesystem = _filesystem_
          o.listener = _listener_
        end
      end

      # ==

      PersistenceToolkit_ = Lazy_.call do
        Home_.lib_.ACS::GitConfigMagnetics
      end

      # ==
      # ==
    end
  end
end
