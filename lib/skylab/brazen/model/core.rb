module Skylab::Brazen

  class Model  # read [#013]

    class << self

      # ~ ordering writer (:+#experimental alternative to the iambic DSL)

      def after sym
        @after_name_symbol = sym ; nil
      end

      attr_accessor :after_name_symbol

      # ~ description support

      attr_accessor :description_block

      # ~ model identification

      def process_some_customized_inflection_behavior scanner
        Process_customized_model_inflection_behavior__[ scanner, self ]
      end

      def natural_key_string
        properties.fetch NAME_
      end

      def node_identifier
        @node_id ||= Node_Identifier_.via_name_function name_function, self
      end

      def name_function_class  # #hook-in for above
        Model_Name_Function_
      end

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

      def is_branch
        true  # for now, every model node exists (in the eyes of invocation
        # engines) only to dispatch each request down to one of its children
      end

      def is_promoted
        NIL_
      end

      # Library Exposures

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

      def make_common_properties & edit_p
        common_properties_class.new entity_module, & edit_p
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

    include Callback_::Actor.methodic_lib.iambic_processing_instance_methods

    include Brazen_::Entity::Instance_Methods

    include module Interface_Element_Instance_Methods___

      def name
        self.class.name_function
      end

      def is_visible
        ! is_invisible
      end

      def is_branch
        true  # see comments at same method above
      end

      def to_kernel
        @kernel
      end

      attr_reader :is_invisible

      def has_description
        ! self.class.description_block.nil?
      end

      def under_expression_agent_get_N_desc_lines expression_agent, d=nil
        LIB_.N_lines.
          new( [], d, [ self.class.description_block ], expression_agent ).
           execute
      end

      def action_property_value i
        ivar = :"@#{ i }"
        instance_variable_defined?( ivar ) or raise say_no_action_prop( i )
        instance_variable_get ivar
      end

    private

      def say_no_action_prop i
        "action prop not set: '#{ i }'"
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

    def is_visible
      true
    end

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
      LIB_.basic.trio(
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

    class Subsequent_Edit_Tree___ < Edit_Tree__
      def to_a
        [ delta_box ]
      end
    end

    class Edit_Tree__

      def initialize
        @delta_box = nil
      end

      attr_reader :delta_box

      def delta_box_
        @delta_box ||= Callback_::Box.new
      end
    end

    class Edit_Session__

      def initialize tree, formals
        @formals = formals
        @tree = tree
      end

      def preconditions x
        @tree.preconditions_ = x
        nil
      end

      def edit_magnetically_from_box pairs  # e.g by a generated action
        bx = @tree.delta_box_
        fo = @formals
        pairs.each_pair do | k, x |
          fo.has_name k or next
          bx.add k, x  # chanage to `set` when necessary
        end
        nil
      end

      def edit_with * x_a  # e.g by hand
        edit_via_iambic x_a
      end

      def edit_via_iambic x_a
        bx = @tree.delta_box_
        fo = @formals
        st = Callback_::Polymorphic_Stream.via_array x_a
        while st.unparsed_exists
          prp = fo.fetch st.gets_one
          if prp.takes_argument
            bx.add prp.name_symbol, st.gets_one  # change to `set` when necessary
          else
            self._COVER_ME
          end
        end
        nil
      end

      def edit_pair x, k  # e.g by hand
        if @formals.has_name k
          @tree.delta_box_.add k, x
        else
          @tree.strange_i_a_.push k
        end
        nil
      end

      def edit_pairs pairs, * p_a, & p  # e.g unmarshal

        p and p_a.push p
        x_p, k_p = p_a
        x_p ||= IDENTITY_
        k_p ||= IDENTITY_

        bx = @tree.delta_box_
        fo = @formals
        pairs.each_pair do | k, x |

          k = k_p[ k ]
          x = x_p[ x ]

          if fo.has_name k
            bx.add k, x
          else
            @tree.strange_i_a_.push k  # [#037] one day..
          end
        end
        nil
      end
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

 public  # ~ multipurpose internal readers & callbacks

    attr_reader :preconditions

    def properties
      @property_box or fail "no prop box for #{ self.class }"
    end

    # ~ adjunct & experiments

    def __accept_selective_event_listener x
      @__HESVC_p__ = nil
      @on_event_selectively = x ; nil
    end

    class Process_customized_model_inflection_behavior__

      Actor_[ self, :properties, :scanner, :cls ]

      def execute
        :noun == @scanner.current_token or raise ::ArgumentError, say_only
        @scanner.advance_one
        x = @scanner.current_token
        if :with_lemma == x
          @scanner.advance_one
          x = @scanner.current_token
        end
        x.respond_to? :ascii_only? or raise ::ArgumentError, say_string
        @scanner.advance_one
        acpt Customized_Model_Inflection__.new x
      end

      def say_only
        "the only kind of inflection a model may customize is 'noun' #{
          }(had '#{ @scanner.current_token }')"
      end

      def say_string
        "noun lemma must be a string (had #{ @scanner.current_token.inspect })"
      end

      def acpt _MODEL_INFLECTION_
        @cls.send :define_singleton_method, :custom_branch_inflection do
          _MODEL_INFLECTION_
        end
        KEEP_PARSING_
      end
    end

    class Customized_Model_Inflection__

      def initialize s
        @noun_lemma = s
      end

      attr_reader :noun_lemma

    end

    class Model_Name_Function_ < Brazen_.name_library.name_function_class

      def init_via_three_ cls, parent, const_i

        @cls = cls
        super
      end

      attr_reader :cls

      def inflected_noun
        inflection_kernel.inflected_noun
      end

      def noun_lexeme
        inflection_kernel.noun_lexeme
      end

    private
      def inflection_kernel
        @inflection_kernel ||= Model_::Inflection_Kernel__.for_model self
      end
    end

    class Flyweighted_Property_Box__

      # if iterating over a dataset, only allocate memory when you chose to

      def initialize unbound

        @_h = nil
        @_hash_is_mine = false

        symbol_to_string_h = {}
        unbound.properties.get_names.each do |i|
          symbol_to_string_h[ i ] = i.id2name
        end

        @_SHARED_symbol_to_string = symbol_to_string_h
      end

      def initialize_copy _

        unless @_hash_is_mine
          @_h = @_h.dup
          @_hash_is_mine = true
        end
        NIL_
      end

      def [] sym

        s = @_SHARED_symbol_to_string[ sym ]
        s and @_h[ s ]
      end

      def fetch sym, & p

        s = @_SHARED_symbol_to_string[ sym ]
        if s
          @_h.fetch s, & p
        elsif p
          p[]
        else
          raise ::KeyError, __say_key_error( sym )
        end
      end

      def __say_key_error sym
        "key not found: '#{ sym }'"
      end

      def replace_name_in_hash s

        if @_h
          @_hash_is_mine = false
        else
          @_h = {}
          @_hash_is_mine = false
          # the hash still isn't yours - you're a flyweight
        end

        @_h[ NAME_S___ ] = s

        NIL_
      end

      NAME_S___ = NAME_.id2name

      def replace_hash h

        @_hash_is_mine = true
        @_h = h
        NIL_
      end
    end

    # ~ the stack

    class Silo_Daemon

      def initialize kernel, model_class

        @kernel = kernel
        @model_class = model_class

        if @kernel.do_debug
          @kernel.debug_IO.puts(
            ">>          MADE #{ Callback_::Name.via_module( @model_class ).as_slug } SILO" )
        end
      end

      def members
        [ :model_class, :name_symbol ]
      end

      attr_reader :model_class

      def name_symbol
        @model_class.name_function.as_lowercase_with_underscores_symbol
      end

      def call * x_a, & oes_p
        bc = _bound_call_via x_a, & oes_p
        bc and bc.receiver.send( bc.method_name, * bc.args )
      end

      def bound_call * x_a, & oes_p
        _bound_call_via x_a, & oes_p
      end

      def _bound_call_via x_a, & oes_p

        sess = Brazen_::API.bound_call_session.start_via_iambic x_a, @kernel, & oes_p
        sess.receive_top_bound_node @model_class.new( @kernel, & oes_p )

        if sess.via_current_branch_resolve_action_promotion_insensitive
          st = sess.iambic_stream
          h = { trio_box: nil, preconditions: nil }
          while st.unparsed_exists
            if :with == st.current_token
              st.advance_one
              break
            end
            k = st.gets_one
            h.fetch k  # validate
            h[ k ] = st.gets_one
          end
          preconds = h[ :preconditions ]
          trio_box = h[ :trio_box ]
          h = nil

          act = sess.bound
          act.first_edit

          if preconds
            act.receive_starting_preconditions preconds
          end

          ok = true
          if trio_box
            ok = act.process_pair_box_passively trio_box
          end

          ok &&= act.process_iambic_stream_fully_ st
          ok and act.via_arguments_produce_bound_call
        else
          sess.bound_call
        end
      end

      # ~

      def any_mutated_formals_for_depender_action_formals x  # :+#public-API #hook-in

        # override this IFF your silo wants to add to (or otherwise mutate)
        # the formal properties of every client action that depends on you.

        my_name_sym = @model_class.node_identifier.full_name_i

        a = @model_class.preconditions
        if a and a.length.nonzero?
          x_ = x
          a.each do | silo_id |
            if my_name_sym == silo_id.full_name_i
              next
            end
            x__ = @kernel.silo_via_identifier( silo_id ).
              any_mutated_formals_for_depender_action_formals x_
            if x__
              x_ = x__
            end
          end
        end
        x_  # nothing by default
      end

      def precondition_for action, id, box, & oes_p
        id = @model_class.persist_to
        if id

          # assume this is an "ordinary" business silo with collection and so
          # its precondition *is* the collection. we could also place a dummy
          # value here and let the entity fetch the d.s from the box itself.

          box.fetch id.full_name_i
        else
          _implement_me
        end
      end

      def precondition_for_self( * )
        _implement_me
      end

      def _implement_me
        _loc = caller_locations( 1 ..1 ).first
        raise "implement me - `#{ @model_class }::Silo_Daemon##{ _loc.label }`"
      end
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
