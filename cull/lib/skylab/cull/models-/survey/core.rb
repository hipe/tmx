module Skylab::Cull

  class Models_::Survey

    # == (stowaway actions)

    module Actions
      Autoloader_[ self ]
    end

    class Actions::Ping

      # (if you like, compare to the simpler proc-based one at #spot1.1)

      def initialize
        extend CommonActionMethods_
        init_action_ yield
      end

      def execute

        _listener_.call :info, :ping do

          app_name_string = _microservice_invocation_.app_name_string

          Common_::Event.inline_OK_with(
            :ping,
          ) do |y, o|
            y << "#{ app_name_string } says #{ em "hello" }"
          end
        end

        :_hi_again_
      end
      Actions = nil
    end

    # ==

    module SurveyActionMethods_

      include CommonActionMethods_

      def these_common_associations_
        Common_associations_[]
      end

      def resolve_existent_survey_via_path_

        if __resolve_survey_path_via_path_SRVY
          __resolve_survey_via_survey_path_SRVY
        end
      end

      def __resolve_survey_via_survey_path_SRVY

        # (parse the config file)

        _su_path = remove_instance_variable :@__survey_path

        _ = Here_::Magnetics_::Survey_via_SurveyPath.call_by do |o|
          o.survey_path = _su_path
          o.filesystem = _filesystem_
          o.listener = _listener_
        end

        _store_ :@_survey_, _
      end

      def __resolve_survey_path_via_path_SRVY

        # (walk up from the argument path looking for the special filename)

        _ = Here_::Magnetics_::SurveyPath_via_Path[ @path, & _listener_ ]
        _store_ :@__survey_path, _
      end

      define_method :_store_, DEFINITION_FOR_THE_METHOD_CALLED_STORE_  # (probably move up)
    end

    # ==

    class << self

      def define_survey_
        me = new
        yield me
        me  # (note that at this point you might be known to be invalid, near #spot1.4)
      end

      private :new
    end  # >>

    # == (stowaway magnetics (one))

    module Magnetics_  # (legacy placement)

      SurveyPath_via_Path = -> path, & p do

        arg = Common_::QualifiedKnownKnown.via_value_and_symbol path, :path

        _FS = Home_.lib_.system_lib::Filesystem

        surrounding_path = _FS::Walk.via(
          :start_path, arg.value,
          :filename, FILENAME_,
          :ftype, _FS::DIRECTORY_FTYPE,
          :max_num_dirs_to_look, -1,
          :prop, arg.association,
          & p )

        if surrounding_path
          ::File.join surrounding_path, FILENAME_
        end
      end
    end

    def initialize
        @_mutex_for_config = nil
        @persist_step_a = EMPTY_A_  # this is going away or full overhaul. setting it to this asserts that it is not used
    end

    # ~ all #hook-in to [br] edit session API

      def survey_path= su_path
        @path = ::File.dirname su_path
        @_survey_path = :_survey_path_via_ivar
        @_survey_path_value = su_path
      end

    # ==

    # ~~ interface for the persistence script

    def add_to_persistence_script_ * step
      @persist_step_a.nil? and @persist_step_a = []
      @persist_step_a.push step
      nil
    end

    def flush_persistence_script_
      # (`re_persist` was 1) convert to mutable config, 2) this method, then write config)
      a = @persist_step_a ; @persist_step_a = nil
      ok = true
      if a.length.nonzero?
        self._STOP_THE_INSANITY
      end
      a.each do | m, * args |
        ok = send m, * args
        ok or break
      end
      ok
    end

    # ~~ steps avaiable for the persistence script

    def call_on_associated_entity_ ent_sym, m, * args
      touch_associated_entity_( ent_sym ).send m, * args
    end

    # ~~ misc functions for actors & top entities

      # -- C ..

      def define_and_assign_component_by  # (will be for [ac])

        _ent = MTk_::AssociationToolkit::DefineAndAssignComponent_via_Block_and_Symbol.call_by do |o|
          yield o
          o.mutable_entity = self
        end

        _ent # hi. #todo on success, the entity that was added
      end

      def write_component_via_primitives_by__

        _ok = Here_::Magnetics_::WriteComponent_via_Primitives_and_Survey.call_by do |o|
          yield o
          o.survey = self
        end

        _ok  # hi. #todo
      end

      # -- B ..

      def accept_initial_config_ cfg
        remove_instance_variable :@_mutex_for_config
        if cfg.is_mutable
          _accept_mutable_config cfg
        else
          @config_for_read_ = :__read_only_config
          @config_for_write_ = :__convert_config_once
          @_read_only_config = cfg
        end
        NIL
      end

      def config_for_write_
        send @config_for_write_
      end

      def config_for_read_
        send @config_for_read_
      end

      def __convert_config_once

        _cfg = remove_instance_variable :@_read_only_config
        _bur = _cfg.document_byte_upstream_reference

        _cfg = Git_config_[]::Mutable.parse_document_by do |o|
          o.byte_upstream_reference = _bur
          # (can't listen)
        end

        _accept_mutable_config _cfg
        send @config_for_write_
      end

      def _accept_mutable_config cfg
        @config_for_write_ = :_mutable_config
        @config_for_read_ = :_mutable_config
        @_mutable_config = cfg ; nil
      end

      def _mutable_config
        @_mutable_config
      end

      def __read_only_config
        @_read_only_config
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # -- A: popular readers

      def persist_by_
        # was `re_persist`
        Here_::Magnetics_::PersistSurvey_via_Survey.call_by do |o|
          yield o
          o.survey = self
        end
      end

      def to_event
        _path = survey_path_
        Common_::Event.inline_OK_with(
          :survey,
          :path, _path,
          :is_completion, true,
        )
      end

      def maybe_relativize_path__ path

        _head = survey_path_

        relpath = Home_.lib_.basic::Pathname::Relative_path_from[ path, _head ]

        relpath.length < path.length ? relpath : path
      end

      def _derelativize_by_
        method :__derelativize_path
      end

      def __derelativize_path path
        head = survey_path_
        if head
          ::File.join head, path
        end
      end

      def survey_path_
        send ( @_survey_path ||= :__survey_path_initially )
      end

      def __survey_path_initially
        @path || self._RECONSIDER_ME__see_that_other_thing__  # #here1
        @_survey_path_value = ::File.join( @path, FILENAME_ ).freeze
        send( @_survey_path = :_survey_path_via_ivar )
      end

      def _survey_path_via_ivar
        @_survey_path_value
      end

      def to_stream_of_qualified_components__
        MTk_::AssociationToolkit::QualifiedComponentStream_via_Entity[ self ]
      end

      # ~(

      def _insert_via_index_and_association_ x, d, asc

        # (stay close to `_insert_via_index_and_association_symbol_`)

        -1 == d || self._COVER_ME__ad_hoc_inserts_not_yet_implemented_
        ivar = asc.name.as_ivar
        if instance_variable_defined? ivar
          a = instance_variable_get ivar
        else
          a = []
          instance_variable_set ivar, a
        end
        a.push x ; nil
      end

      def _write_via_association_ x, asc  # near `_simplified_write_`
        _ivar = asc.name.as_ivar
        instance_variable_set _ivar, x
        NIL
      end

      def _unset_via_association_ asc
        _ivar = asc.name.as_ivar
        remove_instance_variable _ivar
      end

      def _knows_value_for_association_ asc
        ivar = asc.name.as_ivar
        if instance_variable_defined? ivar
          x = instance_variable_get ivar
          x.nil? and self._NEVER__no_big_deal_readme__  # #todo
          true
        end
      end

      def _read_softly_via_association_ asc
        ivar = asc.name.as_ivar
        if instance_variable_defined? ivar
          x = instance_variable_get ivar
          x.nil? and self._NEVER__no_big_deal_readme__  # #todo
            # (let's only ever have ivar "defined" coincide with being "set")
          x
        end
      end

      def _associations_feature_branch_
        Here_::Associations_.boxxy_module_as_feature_branch
      end

      def _models_feature_branch_  # :#spot2.1
        _models_module_.boxxy_module_as_feature_branch
      end

      def _THESE_ASSOCIATIONS_
        Common_associations_[]
      end

      def _models_module_
        Home_::Models_
      end

      # ~)

    # -
    # ==

    module Associations_

      Autoloader_[ self, :boxxy ]
      # (this is the frontier use-case [#co-030.5] boxxy as feature branch)

      same = -> c do
        Here_.const_get :FunctionBasedAssociations_, false
        const_defined? c, false or fail
        const_get c, false
      end

      lazily :CurriedFunctions, & same
    end

    # ==

    Common_associations_ = Lazy_.call do

      _ca = Home_.lib_.brazen::CommonAssociations.define do |o|

        o.property_grammatical_injection_by do
          MTk_::AssociationToolkit::Pluralton_powered_parameter_grammatical_injection[]
        end

        these = :curried_functions

        o.ADD_ALL_THESE_MUGS(
          :property, :upstream,
          :property, :upstream_adapter,

          :flag, :property, :unset_upstream,

          # ("pluralton" defined at [#ac-024.A.2])

          :property, :add_map, :pluralton_association, these,
          :property, :remove_map, :pluralton_association, these,

          :property, :add_mutator, :pluralton_association, these,
          :property, :remove_mutator, :pluralton_association, these,

          :property, :add_aggregator, :pluralton_association, these,
          :property, :remove_aggregator, :pluralton_association, these,
        )
      end

      _ca.to_dereferenced_item_array
    end

    # ==

    # ==

    module Magnetics_  # re-open

      Autoloader_[ self ]

      lazily :Survey_via_SurveyPath do |c|
        const_get :PersistSurvey_via_Survey, false
        const_defined? c, false or fail
        const_get c
      end
    end

    # ==

    Git_config_ = Lazy_.call do
      Home_.lib_.brazen::CollectionAdapters::GitConfig
    end

    # ==

    CONFIG_FILENAME_ = 'config'.freeze
    EMPTY_A_ = [].freeze
    FILENAME_ = 'cull-survey'.freeze
    Here_ = self
    UNDERSCORE_ = '_'
    UNRELIABLE_ = :_cu_unreliable_

    # ==
    # ==
  end
end
# #history-A.1: when two methods left this file to become something #spot1.2
