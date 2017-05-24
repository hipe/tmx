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
            y << "#{ app_name_string } says #{ highlight "hello" }"
          end
        end

        :_hi_again_
      end
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

      SurveyPath_via_Path = -> path, & oes_p do

        arg = Common_::QualifiedKnownKnown.via_value_and_symbol path, :path

        _FS = Home_.lib_.system_lib::Filesystem

        surrounding_path = _FS::Walk.via(
          :start_path, arg.value,
          :filename, FILENAME_,
          :ftype, _FS::DIRECTORY_FTYPE,
          :max_num_dirs_to_look, -1,
          :prop, arg.association,
          & oes_p )

        if surrounding_path
          ::File.join surrounding_path, FILENAME_
        end
      end
    end

    def initialize
        @_mutex_for_config = nil
        @persist_step_a = EMPTY_A_  # this is going away or full overhaul. setting it to this asserts that it is not used
      @entities = nil
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

    # ~ public API for #:+actors near "associated entities" API (experiment)

    def existent_associated_entity_ ent_sym  # placeholder for etc.
      self._AWAY__this_method__
      @entities.fetch ent_sym
    end

    def touch_associated_entity_ ent_sym
      self._AWAY__this_method__

      if @entities
        ent = @entities[ ent_sym ]
      else
        @entities = {}
      end

      if ! ent

        _const_s = Common_::Name.via_variegated_symbol( ent_sym ).as_camelcase_const_string

        _cls = Models__.const_get _const_s, false

        ent = _cls.new self, & @on_event_selectively

        @entities[ ent_sym ] = ent
      end

      ent
    end

      # -- C ..

      def define_and_assign_component_by__
        _hi = MTk_::AssociationToolkit::DefineAndAssignComponent_via_Block_and_Symbol.call_by do |o|
          yield o
          o.mutable_entity = self
        end
        _hi  # hi. #todo
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
        Here_::Magnetics_::CreateSurvey_via_Survey.call_by do |o|
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

      def _associations_operator_branch_
        Here_::Models__.boxxy_module_as_operator_branch
      end

      def _models_module_
        Models_
      end

    # -
    # ==

    module Models__

      Autoloader_[ self, :boxxy ]
      # (this is the frontier use-case [#co-030.5] boxxy as operator branch)

      same = 'function--'
      stowaway :Map, same
      stowaway :Mutator, same
      stowaway :Aggregator, same
    end

    # ==

    Common_associations_ = Lazy_.call do

      _ca = Home_.lib_.brazen_NOUVEAU::CommonAssociations.define do |o|

        o.property_grammatical_injection_by do
          Build_custom_grammatical_injection_ONCE___[]
        end

        o.ADD_ALL_THESE_MUGS(
          :property, :upstream,
          :property, :upstream_adapter,

          :flag, :property, :unset_upstream,

          :list, :property, :add_map,
          :list, :property, :remove_map,

          :list, :property, :add_mutator,
          :list, :property, :remove_mutator,

          :list, :property, :add_aggregator,
          :list, :property, :remove_aggregator,
        )
      end

      _ca.to_dereferenced_item_array
    end

    Build_custom_grammatical_injection_ONCE___ = -> do

      _inj = Home_.lib_.fields::CommonAssociation::EntityKillerParameter.grammatical_injection

      _inj.redefine do |o|

        mod = MyCustomPrefixedModifiers___
        mod.include o.prefixed_modifiers  # yikes
        o.prefixed_modifiers = mod
      end
    end

    module MyCustomPrefixedModifiers___

      def list

        # (until recently, we use to do this all custom..) now it's a
        # palceholder for the idea of doing something crazy..)

        @parse_tree.be_glob
        KEEP_PARSING_
      end
    end

    # ==

    # ==

    module Magnetics_  # re-open

      Autoloader_[ self ]

      lazily :Survey_via_SurveyPath do |c|
        const_get :CreateSurvey_via_Survey, false
        const_defined? c, false or fail
        const_get c
      end
    end

    # ==

    Git_config_ = Lazy_.call do
      Home_.lib_.brazen_NOUVEAU::CollectionAdapters::GitConfig
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
