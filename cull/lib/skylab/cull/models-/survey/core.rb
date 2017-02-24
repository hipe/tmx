module Skylab::Cull

  class Models_::Survey < Model_

    class << self

      def any_nearest_path_via_looking_upwards_from_path arg, & oes_p

        fs = Home_.lib_.filesystem

        surrounding_path = fs.walk(
          :start_path, arg.value_x,
          :filename, FILENAME_,
          :ftype, fs.constants::DIRECTORY_FTYPE,
          :max_num_dirs_to_look, -1,
          :prop, arg.association,
          & oes_p )

        if surrounding_path
          ::File.join surrounding_path, FILENAME_
        else
          surrounding_path
        end
      end
    end  # >>

    def initialize k
      @cfg_for_read = nil
      @entities = nil
      @persist_step_a = nil
      super k
    end

    # ~ all #hook-in to [br] edit session API

    def first_edit_shell
      subsequent_edit_shell
    end

    def subsequent_edit_shell
      Edit_Shell__.new
    end

    def process_first_edit sh
      process_subsequent_edit sh
    end

    def process_subsequent_edit sh
      send sh.m, * sh.a
    end

    # ==

    class Edit_Shell__

      def initialize
      end

      attr_reader :m, :a

      def create_via_mutable_qualified_knownness_box_and_look_path bx, path
        _call :__create_via_mutable_qualified_knownness_box_and_look_path, bx, path
      end

      def edit_via_mutable_qualified_knownness_box_and_look_path bx, path
        _call :__edit_via_mutable_qualified_knownness_box_and_look_path, bx, path
      end

      def edit_via_mutable_qualified_knownness_box__ bx
        _call :_edit_via_mutable_qualified_knownness_box, bx
      end

      def retrieve_via_workspace_path path
        _call :_retrieve_via_workspace_path, path
      end

    private

      def _call i, * a
        @m = i ; @a = a ; nil
      end
    end

    # ==

    def __create_via_mutable_qualified_knownness_box_and_look_path bx, path
      @_path = path
      @persist_step_a ||= []
      @persist_step_a.push [ :__create_editable_document ]

      _edit_via_mutable_qualified_knownness_box bx
    end

    def __edit_via_mutable_qualified_knownness_box_and_look_path bx, path

      ok = _retrieve_via_workspace_path ::File.join( path, FILENAME_ )
      if ok
        _edit_via_mutable_qualified_knownness_box bx
      else
        ok
      end
    end

    def _retrieve_via_workspace_path ws_path

      _config_path = ::File.join ws_path, CONFIG_FILENAME_

      cfg = Brazen_.collections::Git_Config.parse_path(
        _config_path,
        & @on_event_selectively )

      cfg and begin
        @_path = ::File.dirname ws_path
        @cfg_for_write = nil
        @cfg_for_read = cfg
        self
      end
    end

    def path
      @_path
    end

    def _edit_via_mutable_qualified_knownness_box bx

      arg_a = bx.to_value_stream.reduce_by do | arg |
        arg.is_known_known && :path != arg.name_symbol
      end.to_a

      if arg_a.length.zero?
        self
      else

        _ok = Here_::Actors__::Edit_associated_entities.call(
          arg_a, bx, self, & @on_event_selectively )

        _ok and self
      end
    end

    # ~ public API for :+#actors near persistence

    # ~~ flushers

    def re_persist is_dry  # assume a config for read

      @cfg_for_write = Brazen_.collections::Git_Config::Mutable.parse_input_id(
        @cfg_for_read.input_id, & @on_event_selectively )

      @cfg_for_read = nil

      flush_persistence_script_ and _write( is_dry )
    end

    def write_ is_dry

      ::Dir.mkdir workspace_path_  # dry? atomic? meh

      _write is_dry
    end

    def _write is_dry

      @cfg_for_write.write_to_path(  # results in true on success

        ::File.join( workspace_path_, CONFIG_FILENAME_ ),
        :is_dry, is_dry,
        & @on_event_selectively )
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

    def __create_editable_document
      @cfg_for_read = nil
      @cfg_for_write = Brazen_.collections::Git_Config::Mutable.new(
        & @on_event_selectively )
      ACHIEVED_
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
      @___did_calc_WS_path ||= begin
        if @_path
          @__ws_path = ::File.join @_path, FILENAME_
        end
        true
      end
      @__ws_path
    end

    def persist_box_and_value_for_name_symbol_ box, value_string, section_symbol

      cfg = @cfg_for_write

      delete_these, change_the_name_of_this_one = ___all_become_one section_symbol

      if delete_these
        cfg.sections.delete_these_ones delete_these
      end

      if change_the_name_of_this_one
        change_the_name_of_this_one.set_subsection_name value_string
        guy = change_the_name_of_this_one
      else
        guy = cfg.sections.touch_section value_string, section_symbol
      end

      guy and begin
        asts = guy.assignments
        if asts.length.nonzero?
          self._DO_ME
        end
        if box.length.zero?
          ACHIEVED_
        else
          box.each_pair do | sym, x |
            asts.add_to_bag_mixed_value_and_name_function x, Common_::Name.via_variegated_symbol( sym )
          end
          ACHIEVED_
        end
      end
    end

    def ___all_become_one section_symbol

      st = @cfg_for_write.sections.to_value_stream.reduce_by do | x |
        section_symbol == x.external_normal_name_symbol
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

      st = cfg.sections.to_value_stream.reduce_by do | x |
        section_sym == x.external_normal_name_symbol
      end

      delete_these = st.to_a

      if delete_these.length.zero?
        name_sym = :"no_#{ section_sym }_set"
        @on_event_selectively.call :error, name_sym do
          Build_not_OK_event_[ name_sym ]
        end
        UNABLE_
      else
        a = cfg.sections.delete_these_ones delete_these
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

    def to_event
      Common_::Event.inline_OK_with :survey,
        :path, ::File.join( @_path, FILENAME_ ),
        :is_completion, true
    end

    def workspace_path_
      @___ws_path ||= ::File.join @_path, FILENAME_
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

    # ==

    module Actions
      Autoloader_[ self, :boxxy ]
    end

    # ==

    module Models__

      define_singleton_method :tricky_index__, ( Lazy_.call do
        Build_tricky_index___[ self ]
      end )

      Autoloader_[ self, :boxxy ]

      same = 'function--'
      stowaway :Map, same
      stowaway :Mutator, same
      stowaway :Aggregator, same
    end

    LIST_WRITER_MPP___ = -> prp do  # must be defined before below

      _SYM = prp.name_symbol

      -> do
        _x = gets_one_polymorphic_value
        @argument_box.touch_array_and_push _SYM, _x
        KEEP_PARSING_
      end
    end

    # ==

    module Survey_Action_Methods_

      def self.receive_entity_property prp

        if prp.has_custom_polymorphic_writer_method

          m = prp.custom_polymorphic_writer_method_name
          _method_definition = prp.polymorphic_writer_method_proc_proc[ prp ]

          es = @entity_edit_session
          @entity_edit_session = nil
          define_method m, & _method_definition
          @entity_edit_session = es

          private m
        end
        KEEP_PARSING_
      end

      Common_entity_.call self do

        const_set :Property, ::Class.new( const_get( :Property  ) )

        class self::Property

          attr_reader :_wmeth

        private

          def list=  # :+#[br-082]

            @argument_arity = :_defined_manually_
            @has_custom_polymorphic_writer_method = true
            @polymorphic_writer_method_proc_proc = LIST_WRITER_MPP___
            KEEP_PARSING_
          end

          def normalize_property

            if has_custom_polymorphic_writer_method
              set_polymorphic_writer_method_name(
                conventional_polymorphic_writer_method_name )
            end
            KEEP_PARSING_
          end
        end

        o :property, :upstream,
          :property, :upstream_adapter,

          :list, :property, :add_map,
          :list, :property, :remove_map,

          :list, :property, :add_mutator,
          :list, :property, :remove_mutator,

          :list, :property, :add_aggregator,
          :list, :property, :remove_aggregator
      end

    private

      def via_path_argument_resolve_existent_survey

        _qualified_knownness = qualified_knownness :path

        path = Models_::Survey.any_nearest_path_via_looking_upwards_from_path(
          _qualified_knownness,
          & @on_event_selectively )

        path and ___resolve_existent_survey_via_existent_path path
      end

      def ___resolve_existent_survey_via_existent_path path

        sv = Models_::Survey.edit_entity @kernel, @on_event_selectively do | edit |
          edit.retrieve_via_workspace_path path
        end

        sv and begin
          @survey = sv
          ACHIEVED_
        end
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

    COMMON_PROPERTIES_ = Survey_Action_Methods_.properties.to_value_stream.to_a
    CONFIG_FILENAME_ = 'config'.freeze
    FILENAME_ = 'cull-survey'.freeze
    Here_ = self
    UNRELIABLE_ = :_cu_unreliable_
  end
end
