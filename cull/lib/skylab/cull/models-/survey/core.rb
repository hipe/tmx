module Skylab::Cull

  class Models_::Survey

    # (#used-to-descend-model)

    module Actions
      Autoloader_[ self ]
    end

    class Actions::Ping

      # (if you like, compare to the simpler proc-based one at #spot1-1)

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

    class << self

      def define_sanitized_
        me = new
        yield me
        me.__become_self
      end
      private :new
    end  # >>

    # NOTE 
    # we are in the middle of a "progressive full

    module Magnetics_  # (legacy placement)

      SurveyPath_via_Path = -> path, & oes_p do

        arg = Common_::Qualified_Knownness.via_value_and_symbol path, :path

        _FS = Home_.lib_.system_lib::Filesystem

        surrounding_path = _FS::Walk.via(
          :start_path, arg.value_x,
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
      @cfg_for_read = nil
      @entities = nil
      @persist_step_a = nil
    end

    # ~ all #hook-in to [br] edit session API

    attr_writer(
      :cfg_for_read,
      :cfg_for_write,
      :path,
    )

    def __become_self
      self  # hi.
    end

    # ==

    def __create_via_mutable_qualified_knownness_box_and_look_path bx, path
      @_path = path
      @persist_step_a ||= []
      @persist_step_a.push [ :__create_editable_document ]

      _edit_via_mutable_qualified_knownness_box bx
    end

    def _edit_via_mutable_qualified_knownness_box bx

      arg_a = bx.to_value_stream.reduce_by do | arg |
        arg.is_known_known && :path != arg.name_symbol
      end.to_a

      if arg_a.length.zero?
        self
      else

        _ok = Here_::Magnetics_::EditEntities_via_Request_and_Survey.call(
          arg_a, bx, self, & @on_event_selectively )

        _ok and self
      end
    end

    # ~ public API for :+#actors near persistence

    # ~~ flushers

    def re_persist is_dry  # assume a config for read

      # convert a read-only document to a mutable document "by hand"

      _r_cfg = remove_instance_variable :@cfg_for_read

      bur = _r_cfg.document_byte_upstream_reference

      cfg = Git_config_[]::Mutable.parse_document_by do |o|
        o.byte_upstream_reference = bur
        o.listener = @on_event_selectively
      end

      cfg || self._SANITY__why_did_it_not_parse__it_was_OK_before__

      @cfg_for_write = cfg

      _ok = flush_persistence_script_
      _ok and _write is_dry
    end

    def write_ p, is_dry

      ::Dir.mkdir survey_path_  # dry? atomic? meh

      _write p, is_dry
    end

    def _write p, is_dry

      _path = ::File.join survey_path_, CONFIG_FILENAME_

      @cfg_for_write.write_to_path_by do |o|
        o.path = _path
        o.is_dry = is_dry
        o.listener = p
      end  # number of bytes
    end

    # ~~ interface for the persistence script

    def add_to_persistence_script_ * step
      @persist_step_a.nil? and @persist_step_a = []
      @persist_step_a.push step
      nil
    end

    def flush_persistence_script_
      a = @persist_step_a ; @persist_step_a = nil
      ok = true
      a.each do | m, * args |
        ok = send m, * args
        ok or break
      end
      ok
    end

    # ~~ steps avaiable for the persistence script

    def init_for_create__

      @cfg_for_read = nil

      @cfg_for_write = Git_config_[]::Mutable.new_empty_document

      @persist_step_a = EMPTY_A_  # assertion

      NIL
    end

    def call_on_associated_entity_ ent_sym, m, * args
      touch_associated_entity_( ent_sym ).send m, * args
    end

    # ~~ misc functions for actors & top entities

    def config_for_read_
      @cfg_for_read
    end

    def config_for_write_
      @cfg_for_write
    end

    def derelativize path
      pth = _workspace_path and ::File.join( pth, path )
    end

    def maybe_relativize_path path

      _from = _workspace_path

      relpath = Home_.lib_.basic::Pathname::Relative_path_from[ path, _from ]

      if relpath.length < path.length
        relpath
      else
        path
      end
    end

    def _workspace_path
      self._HEY__readme__  # see #here1
      @___did_calc_WS_path ||= begin
        if @_path
          @__ws_path = ::File.join @_path, FILENAME_
        end
        true
      end
      @__ws_path
    end

    def persist_box_and_value_for_name_symbol_ bx, value_string, section_sym

      cfg = @cfg_for_write

      delete_these, change_the_name_of_this_one = ___all_become_one section_sym

      if delete_these
        cfg.sections.delete_sections_via_sections delete_these
      end

      if change_the_name_of_this_one
        change_the_name_of_this_one.SET_SUBSECTION_NAME value_string
        section = change_the_name_of_this_one
      else
        _section_name_s = section_sym.id2name  # ..
        section = cfg.sections.touch_section value_string, _section_name_s
      end

      section and __via_section_and_box section, bx
    end

    def __via_section_and_box section, bx

      _has = section.assignments.first

      if _has
        self._COVER_ME__watch_carefully_what_happens__
      end

      bx.each_pair do |sym, x|
        if x.respond_to? :id2name
          x = x.id2name  # you can't store symbols directly in the config
        end
        section.assign x, sym
      end

      ACHIEVED_
    end

    def ___all_become_one section_sym

      st = @cfg_for_write.sections.to_stream_of_sections.reduce_by do |el|
        section_sym == el.external_normal_name_symbol
      end

      sec = st.gets
      if sec
        change_the_name_of_this_one = sec
        sec = st.gets
        if sec
          delete_these = [ sec ]
          sec = st.gets
          while sec
            delete_these.push sec
            sec = st.gets
          end
        end
      end

      [ delete_these, change_the_name_of_this_one ]
    end

    def destroy_all_persistent_nodes_for_name_symbol_ section_sym

      cfg = @cfg_for_write

      st = cfg.sections.to_stream_of_sections.reduce_by do |el|
        section_sym == el.external_normal_name_symbol
      end

      delete_these = st.to_a

      if delete_these.length.zero?
        name_sym = :"no_#{ section_sym }_set"
        @on_event_selectively.call :error, name_sym do
          Build_not_OK_event_[ name_sym ]
        end
        UNABLE_
      else
        a = cfg.sections.delete_sections_via_sections delete_these
        @on_event_selectively.call :info, :"deleted_#{ section_sym }" do
          bld_deleted_slotular a, section_sym
        end
        ACHIEVED_
      end
    end

    def bld_deleted_slotular a, sym

      Build_event_.call( :"deleted_#{ sym }#{ 's' if 1 != a.length }",
        :symbol, sym,
        :count, a.length,
        :ok, true,
      ) do |y, o|
        if 1 == o.count
          y << "deleted #{ par o.symbol.id2name }"
        else
          y << "deleted #{ o.count } #{ par plural_noun o.symbol.id2name }"
        end
      end
    end

    # ~ public API for #:+actors near "associated entities" API (experiment)

    def existent_associated_entity_ ent_sym  # placeholder for etc.
      @entities.fetch ent_sym
    end

    def touch_associated_entity_ ent_sym

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

    # ~ misc public API for actors and actions

    def to_datapoint_stream_for_synopsis
      @cfg_for_read.to_section_stream( & @on_event_selectively ).map_by do | x |
        Here_::Models__::SectionSummary.new x
      end
    end

      # -- B: this support

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      # -- A: popular readers

      def to_event
        _path = survey_path_
        Common_::Event.inline_OK_with(
          :survey,
          :path, _path,
          :is_completion, true,
        )
      end

      def survey_path_
        send ( @_survey_path ||= :__survey_path_initially )
      end

      def __survey_path_initially
        @path || self._RECONSIDER_ME__see_that_other_thing__  # #here1
        @__survey_path = ::File.join( @path, FILENAME_ ).freeze
        send( @_survey_path = :__survey_path )
      end

      def __survey_path
        @__survey_path
      end

    # -
    # ==

    module Models__

      define_singleton_method :tricky_index__, ( Lazy_.call do
        Home_._LETS_FIX_THIS
        Build_tricky_index___[ self ]
      end )

      Autoloader_[ self, :boxxy ]

      same = 'function--'
      stowaway :Map, same
      stowaway :Mutator, same
      stowaway :Aggregator, same
    end

    # ==

    module SurveyActionMethods_

      include CommonActionMethods_

      def these_common_properties_
        These___[]
      end
    end  # (will re-open)

    These___ = Lazy_.call do

      _ca = Home_.lib_.brazen_NOUVEAU::CommonAssociations.define do |o|

        o.property_grammatical_injection_by do
          Build_custom_grammatical_injection_ONCE___[]
        end

        o.ADD_ALL_THESE_MUGS(
          :property, :upstream,
          :property, :upstream_adapter,

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

        @parse_tree.will_normalize_by do |xx, & pp|
          ::Kernel._OKAY
        end
        KEEP_PARSING_
      end
    end

    # ==

    Build_tricky_index___ = -> mod do

      # workaround for new autoloader - reflect on all nodes in filesystem
      # plus all registered stowaways.
      # (boxxy doesn't reflect on stowaways but maybe it should [#co-041])

      h = {}

      st = mod.entry_tree.to_asset_reference_stream
      begin
        sm = st.gets
        sm || break
        h[ sm.entry_group_head ] = true
        redo
      end while nil

      mod.stowaway_hash_.keys.each do |k|
        _slug = Common_::Name.via_const_symbol( k ).as_slug
        h[ _slug ] = true
      end

      h
    end

    # ==

    module SurveyActionMethods_
      define_method :_store_, DEFINITION_FOR_THE_METHOD_CALLED_STORE_  # (probably move up)
    end

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
    UNRELIABLE_ = :_cu_unreliable_

    # ==
    # ==
  end
end
