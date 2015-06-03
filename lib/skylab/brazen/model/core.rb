module Skylab::Brazen

  class Model  # read [#013]

    class << self

      # ~ model API ancillaries & adjunctives

      # ~~ description & name

      attr_accessor :description_block

      def natural_key_string
        properties.fetch NAME_
      end

      def node_identifier
        @node_id ||= Node_Identifier_.via_name_function name_function, self
      end

      def name_function_class  # #hook-in for above
        Model_Name_Function_
      end

      # ~~ inflection

      def process_some_customized_inflection_behavior scanner
        Process_customized_model_inflection_behavior__[ scanner, self ]
      end

      # ~~ placement

      def after sym
        @after_name_symbol = sym ; nil
      end

      attr_accessor :after_name_symbol

      # ~ persistence (reading, writing)

      def unmarshalled kernel, oes_p, & edit_p  # produce an entity from pers.

        edit_entity_directly kernel, oes_p do

          @came_from_persistence = true

        end.first_edit( & edit_p )
      end

      def persist_to

        @did_resolve_persist_to ||= __resolve_persist_to
        @persist_to
      end

      def __resolve_persist_to

        sym = _persist_to_sym

        @persist_to = if sym
          Node_Identifier_.via_symbol sym
        end

        ACHIEVED_
      end

      attr_reader :_persist_to_sym

      def persist_to= sym
        @_persist_to_sym = sym
      end

      # ~ preconditions (reading, writing)

      def preconditions
        @__did_resolve_pcia ||= __resolve_precondition_controller_identifer_a
        @preconditions
      end

      def __resolve_precondition_controller_identifer_a

        i_a = precondition_controller_i_a_
        x = persist_to

        if i_a
          a = i_a.map do |i|
            Node_Identifier_.via_symbol i
          end
          if x
            a.push x
          end
        elsif x
          a = [ x ]
        end

        @preconditions = a  # can be nil
        ACHIEVED_
      end

      attr_accessor :precondition_controller_i_a_

      # ~ making actions

      def make_action_making_actions_module  # writer

        factory = Model_::Action_Factory__.make self, action_class, entity_module
        const_set :Factory___, factory
        factory.make_actions_module
      end

      def action_class
        main_model_class.const_get :Action, false
      end

      # ~ producing entities

      def new_flyweight kernel, & oes_p

        me = self
        edit_entity_directly kernel, oes_p do
          @property_box = Flyweighted_Property_Box__.new me
        end
      end

      def edit_entity boundish, oes_p, & edit_p

        new( boundish, & oes_p ).first_edit( & edit_p )
      end

      def edit_entity_directly boundish, oes_p, & edit_p

        o = new boundish, & oes_p
        o.instance_exec( & edit_p )
        o
      end

      # ~~ editing self as an entity

      def edit_entity_class * x_a, & edit_p

        entity_module.call_via_client_class_and_iambic self, x_a, & edit_p
      end

      # ~~ making & enhancing entity nodes

      def entity * a, & edit_p  # :+#cp:here

        if a.length.nonzero?
          entity_module.via_nonzero_length_arglist a, & edit_p

        elsif edit_p
          entity_module.via( & edit_p )

        else
          self._FIX_ME
        end
      end

      # ~~ support

      def entity_module
        main_model_class.const_get :Entity, false
      end

      def main_model_class
        superclass
      end

      # ~ static properties

      def is_branch  # 1 of 2
        true
      end

      def is_promoted
        NIL_
      end

      # ~

      def make_common_properties & edit_p
        common_properties_class.new entity_module, & edit_p
      end

      def make_common_common_properties & edit_p
        common_properties_class.new common_entity_module, & edit_p
      end

      # ~ library exposures

      def common_action_class
        Model_::Action
      end

      def common_entity * a, & edit_p  # :+#cp:here

        if a.length.nonzero?
          common_entity_module.via_nonzero_length_arglist a, & edit_p

        elsif edit_p
          common_entity_module.via( & edit_p )

        else
          self._FIX_ME
        end
      end

      def common_entity_module
        Model_::Entity
      end

      def common_events
        Model_::Action_Factory__::Events
      end

      def common_properties_class
        Common_Properties___
      end

      def common_retrieve_methods
        Model_::Action_Factory__.retrieve_methods
      end
    end  # >>

    extend Brazen_.name_library.name_function_proprietor_methods

    # [#013]:#note-A the below order

    include Callback_::Actor.methodic_lib.polymorphic_processing_instance_methods

    include Brazen_::Entity::Instance_Methods

    include module Interface_Element_Instance_Methods___

      # ~~ description & name

      def name
        self.class.name_function
      end

      def has_description
        ! self.class.description_block.nil?
      end

      def under_expression_agent_get_N_desc_lines expression_agent, d=nil
        LIB_.N_lines.
          new( [], d, [ self.class.description_block ], expression_agent ).
           execute
      end

      # ~~ placement & visibility

      def after_name_symbol
        self.class.after_name_symbol
      end

      def is_visible
        true
      end

      # ~~ properties

      def action_property_value i
        ivar = :"@#{ i }"
        instance_variable_defined?( ivar ) or raise __say_no_action_prop( i )
        instance_variable_get ivar
      end

      def __say_no_action_prop i
        "action prop not set: '#{ i }'"
      end

      # ~~ statics

      def is_branch  # 2 of 2
        true  # for now, every model node exists (in the eyes of invocation
        # engines) only to dispatch each request down to one of its children
      end

      def to_kernel
        @kernel
      end

      self
    end

    def initialize boundish, & oes_p  # #note-180 do not set error count here

      @on_event_selectively = oes_p or self._WHERE # #t-odo
      @kernel = boundish.to_kernel
      @kernel.do_debug and @kernel.debug_IO.
        puts ">> >> >> >> MADE #{ name.as_slug } CTRL"
    end

    def accept_parent_node_ x
      # for non-top model nodes
      @parent_node = x ; nil
    end

    # ~ dup-like and dup-related

    def new_via_iambic x_a
      dup.__init_duplication_via_iambic x_a
    end

    protected def __init_duplication_via_iambic x_a
      # (for now we don't go thru normalization - but we might one day)
      x_a.each_slice 2 do  | k, x |
        @property_box.set k, x
      end
      self
    end

    def initialize_copy _otr_  # when entity is flyweight
      @property_box = @property_box.dup
    end

    # ~ multipurpose, simple readers

    attr_reader :came_from_persistence

    def to_even_iambic
      y = []
      st = to_full_pair_stream
      pair = st.gets
      while pair
        y.push pair.name_symbol, pair.value_x
        pair = st.gets
      end
      y
    end

    def to_pair_stream_for_persist
      to_full_pair_stream
    end

    def to_full_pair_stream
      Callback_::Stream.via_nonsparse_array( get_sorted_property_name_i_a ).map_by do |i|
        Callback_::Pair.new any_property_value( i ), i
      end
    end

    def to_normalized_bound_property_scan
      props = formal_properties
      Callback_::Stream.via_nonsparse_array( get_sorted_property_name_i_a ).map_by do |i|
        trio_via_property props.fetch i
      end
    end

    def get_sorted_property_name_i_a
      i_a = formal_properties.get_names
      i_a.sort! ; i_a
    end

    def natural_key_string
      @property_box.fetch NAME_
    end

    def trio sym  # #hook-near action. may soften if needed.
      Callback_::Trio.via_value_and_had_and_property(
        @property_box.fetch( sym ), true, formal_properties.fetch( sym ) )
    end

    def any_property_value i
      @property_box[ i ]
    end

    def property_value_via_property prop
      @property_box.fetch prop.name_symbol
    end

    def normalize_property_value_via_normal_entity prop, ent, & oes_p
      normal_x = ent.property_value_via_symbol prop.name_symbol
      mine_x = property_value_via_symbol prop.name_symbol
      if normal_x != mine_x
        @property_box.replace prop.name_symbol, normal_x
        maybe_send_event :info, :normalized_value do
          bld_normalized_value_event normal_x, mine_x, prop
        end
      end
    end

    def bld_normalized_value_event normal_x, mine_x, prop
      build_OK_event_with :normalized_value, :prop, prop,
          :previous_x, mine_x, :current_x, normal_x do |y, o|
        y << "using #{ ick o.current_x } for #{ par o.prop } #{
         }(inferred from #{ ick o.previous_x })"
      end
    end

    def property_value_via_symbol i  # ( was #note-120 )
      @property_box.fetch i
    end

    # ~ action streaming

    def to_unbound_action_stream
      self.class.to_lower_unbound_action_stream
    end

    def to_lower_unbound_action_stream
      self.class.to_lower_unbound_action_stream
    end

    class << self

      def to_unbound_action_stream
        to_upper_unbound_action_stream
      end

      def to_upper_unbound_action_stream  # :+#public-API
        acr = _action_class_reflection
        acr and acr.to_upper_action_cls_strm
      end

      def to_node_stream
        acr = _action_class_reflection
        acr and acr.to_node_stream
      end

      def to_lower_unbound_action_stream  # :+#public-API
        acr = _action_class_reflection
        acr and acr.to_lower_action_class_stream_
      end

      def to_intrinsic_unbound_action_stream
        acr = _action_class_reflection
        acr and acr.to_node_stream
      end

      def is_actionable
        @did_reslolve_acr ||= init_action_class_reflection
        @is_actionable
      end

      def _action_class_reflection
        @did_reslolve_acr ||= init_action_class_reflection
        @acr
      end

    private

      def init_action_class_reflection
        has = const_defined? ACTIONS_CONST_, false  # #one
        if ! has
          h = entry_tree.instance_variable_get :@h
          if h.key? ACTIONS_DIR__ or h.key? ACTIONS_FILE__
            has = true
          end
        end
        @acr = has && bld_action_class_reflection
        @is_actionable = @acr && true
        true
      end

      def bld_action_class_reflection
        Lazy_Action_Class_Reflection.new self, const_get( ACTIONS_CONST_, false )
      end

      ACTIONS_DIR__ = 'actions'.freeze
      ACTIONS_FILE__ = "#{ ACTIONS_DIR__ }#{ Autoloader_::EXTNAME }"
    end

    class Lazy_Action_Class_Reflection

      def initialize * a
        @cls, @mod = a
      end

      def to_upper_action_cls_strm
        @did ||= work
        Callback_::Stream.via_nonsparse_array @up_a
      end

      def to_lower_action_class_stream_
        @did ||= work
        Callback_::Stream.via_nonsparse_array @down_a
      end

      def to_node_stream
        @did ||= work
        Callback_::Stream.via_nonsparse_array @all_a
      end

      def all_a
        @did ||= work
        @all_a
      end

    private

      def work
        i_a = @mod.constants
        @all_a = [] ; @up_a = [] ; @down_a = []
        i_a.each do |i|
          cls = @mod.const_get i, false
          if ! cls.respond_to? :name
            cls = __try_convert_to_unbound_action_via_mixed cls, i
            cls or next
          end
          @all_a.push cls
          if cls.is_actionable
            if cls.is_promoted
              @up_a.push cls
            else
              @down_a.push cls
            end
          end
        end
        if @down_a.length.nonzero?  # #two
          @up_a.push @cls
        end
        DONE_
      end

      def __try_convert_to_unbound_action_via_mixed x, i

        if x.respond_to? :call

          Proxies_::Proc_As::Unbound_Action.new x, i, @mod, @cls
        end
      end
    end

    # ~ the edit session API - :#public-API :#hook-in

    #   the below methods fugue in pairs continually. every comment in the
    #   first method is relevant to any corresponding part of the second.

    def first_edit & edit_p

      # the result of this is the result of your edit session (the user block)

      sh, tree = first_edit_shell
      edit_p[ sh ]  # only for setting values
      process_first_edit tree || sh
    end

    def edit & edit_p

      sh, tree = subsequent_edit_shell
      edit_p[ sh ]
      process_subsequent_edit tree || sh
    end

  private

    def first_edit_shell
      tree = First_Edit_Tree___.new
      [ Edit_Session__.new( tree, formal_properties ), tree ]
    end

    Edit_Tree__ = ::Class.new

    class First_Edit_Tree___ < Edit_Tree__

      def initialize
        super
        @preconditions_ = nil
      end

      def to_a
        [ @delta_box, @preconditions_ ]
      end

      attr_accessor :preconditions_
    end

    def subsequent_edit_shell
      tree = Subsequent_Edit_Tree___.new
      [ Edit_Session__.new( tree, formal_properties ), tree ]
    end

  private

    def process_first_edit tree

      bx, prcns = tree.to_a

      if bx
        @property_box = bx
      else
        @property_box = Box_.new
      end

      if prcns
        @preconditions = prcns
      end

      _finish_edit
    end

    def process_subsequent_edit tree

      bx = tree.delta_box
      if bx
        @property_box.merge_box! bx
      end

      _finish_edit
    end

    def _finish_edit
      _ok = normalize
      _ok && self
    end

    # ~ end edit session API

  public

    # ~ c r u d

    def intrinsic_persist_before_persist_in_collection( *, & oes_p )
      ACHIEVED_
    end

    def persist_via_action action, & oes_p  # :+public-API :+#hook-in

      # (override this if you need more than just the argument box)

      entity_collection.persist_entity action.argument_box, self, & oes_p
    end

    def intrinsic_delete_before_delete_in_collection _action, & oes_p
      ACHIEVED_
    end

  private

    def entity_collection  # :+#public-API
      @preconditions.fetch self.class.persist_to.full_name_i
    end

  private

    # ~ multipurpose internal producers

    def actual_property_box
      @property_box
    end

    def primary_box
      @property_box
    end

    def any_secondary_box
      @parameter_box
    end

    def silo
      @silo ||= prdc_silo
    end

    def prdc_silo
      @kernel.silo_via_identifier self.class.node_identifier
    end

 public

    #  ~ readers for collaborators

    attr_reader :preconditions

    def properties
      @property_box or fail "no prop box for #{ self.class }"
    end

    # ~ writers for collaborators

    def __accept_selective_event_listener x
      @__HESVC_p__ = nil
      @on_event_selectively = x ; nil
    end

    # ~

    class Common_Properties___ < ::Module

      def initialize entity_module, & sess_p

        @array = -> do
          a = @box[].to_a.freeze
          @array = -> { a }
          a
        end

        @box = -> do
          @did_flush || @flush[]
          bx = @properties_p[]
          @box = -> { bx }
          bx
        end

        @properties_p = -> do
          self.properties
        end

        @did_flush = false
        @flush = -> do
          @did_flush = true
          @flush = nil
          entity_module.touch_extends_and_includes_on_client_class self
          self.edit_entity_class do | sess |
            sess_p[ sess ]
          end
          nil
        end
      end

      def has_name sym
        @box[].has_name sym
      end

      def [] sym
        @box[][ sym ]
      end

      def fetch sym, & p
        @box[].fetch sym, & p
      end

      def array
        @array[]
      end

      def to_stream
        @box[].to_stream
      end

      def box
        @box[]
      end

      def entity_property_class
        if ! @did_flush
          @flush[]
        end
        self::Entity_Property
      end

      def set_properties_proc & p  # if you are making a derivative collection
        @did_flush = true
        @flush = nil
        @properties_p = p
        self
      end
    end

    Model_ = self
  end
end
