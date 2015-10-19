module Skylab::Brazen

  class Model < Interface_Tree_Node_  # read [#013]

    # -- Node as Library --

    class << self

      def common_action_class
        Home_::Action
      end

      def common_entity * a, & edit_p

        _create_or_apply_entity_module common_entity_module, a, & edit_p
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

    # -- Defining the model & producing entities  --

    class << self

      def edit_entity boundish, oes_p, & edit_p

        new( boundish, & oes_p ).first_edit( & edit_p )
      end

      def edit_entity_directly boundish, oes_p, & edit_p

        o = new boundish, & oes_p
        o.instance_exec( & edit_p )
        o
      end

      def entity * a, & edit_p

        _create_or_apply_entity_module entity_enhancement_module, a, & edit_p
      end

      def _create_or_apply_entity_module mod, a, & edit_p

        # make & enhance an entity node

        o = Home_::Entity::Session.new
        o.arglist = a
        o.block = edit_p
        o.extmod = mod
        o.execute
      end

      def make_action_making_actions_module  # writer

        factory = Model_::Action_Factory__.make(
          self,
          action_base_class,
          entity_enhancement_module )

        const_set :Factory___, factory
        factory.make_actions_module
      end
    end

    # -- Concerns --

    Autoloader_[ Concerns__ = ::Module.new ]

    # ~ actionability - identity in & navigation of the interface tree

    class << self

      def action_base_class
        Home_::Action
      end

      def entity_enhancement_module

        if const_defined? :ENTITY_ENHANCEMENT_MODULE
          self::ENTITY_ENHANCEMENT_MODULE
        else
          Model_::Entity
        end
      end

      def is_branch
        true
      end
    end

    def is_branch
      true
    end

    private def entity_collection  # :+#public-API
      @preconditions.fetch self.class.persist_to.full_name_symbol
    end

    def fast_lookup
      NIL_  # not implemented here (yet). promotions ick
    end

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

      def to_unbound_stream
        acr = _action_class_reflection
        acr and acr.to_unbound_stream
      end

      def to_lower_unbound_action_stream  # :+#public-API
        acr = _action_class_reflection
        acr and acr.to_lower_action_class_stream_
      end

      def to_intrinsic_unbound_action_stream
        acr = _action_class_reflection
        acr and acr.to_unbound_stream
      end

      def is_actionable
        @did_reslolve_acr ||= init_action_class_reflection_
        @is_actionable
      end

      def _action_class_reflection
        @did_reslolve_acr ||= init_action_class_reflection_
        @acr
      end

      def init_action_class_reflection_
        has = const_defined? ACTIONS_CONST, false  # #one
        if ! has
          h = entry_tree.instance_variable_get :@h
          if h.key? ACTIONS_DIR__ or h.key? ACTIONS_FILE__
            has = true
          end
        end
        @acr = has && __build_action_class_reflection
        @is_actionable = @acr && true
        true
      end

      def __build_action_class_reflection
        Child_Node_Index.new self, const_get( ACTIONS_CONST, false )
      end
    end

    ACTIONS_DIR__ = 'actions'.freeze

    ACTIONS_FILE__ = "#{ ACTIONS_DIR__ }#{ Autoloader_::EXTNAME }"

    def accept_parent_node_ x
      # for non-top model nodes
      @parent_node = x ; nil
    end

    class Child_Node_Index

      def initialize cls, mod

        @_class = cls
        @_mod = mod
      end

      def to_upper_action_cls_strm

        @_did ||= _work
        Callback_::Stream.via_nonsparse_array @_up_a
      end

      def to_lower_action_class_stream_

        @_did ||= _work
        Callback_::Stream.via_nonsparse_array @_down_a
      end

      def to_unbound_stream

        @_did ||= _work
        Callback_::Stream.via_nonsparse_array @_all_a
      end

      def all_a

        @_did ||= _work
        @_all_a
      end

      def _work

        @_all_a = []
        @_down_a = []
        @_up_a = []

        @_mod.constants.each do | sym |

          cls = @_mod.const_get sym, false

          if ! cls.respond_to? :name
            cls = __try_convert_to_unbound_action_via_mixed cls, sym
            cls or next
          end

          @_all_a.push cls

          if cls.is_actionable
            if cls.is_promoted
              @_up_a.push cls
            else
              @_down_a.push cls
            end
          end
        end

        if @_down_a.length.nonzero?  # #two
          @_up_a.push @_class
        end

        DONE_
      end

      def __try_convert_to_unbound_action_via_mixed x, i

        if x.respond_to? :call

          Home_.lib_.basic::Function::As::Unbound_Action.new x, i, @_mod, @_class
        end
      end
    end

    # ~ description & inflection

    class << self

      def process_some_customized_inflection_behavior scanner
        Model_::Concerns_::Inflection.new( scanner, self ).execute
      end
    end

    # ~ name

    class << self

      def natural_key_string
        properties.fetch NAME_SYMBOL
      end

      def node_identifier

        @node_id ||= Concerns_::Identifier.via_name_function name_function, self
      end

      def name_function_class  # #hook-in for above
        Concerns_::Name
      end
    end

    def natural_key_string
      @property_box.fetch NAME_SYMBOL
    end

    # ~ placement & visibility

    class << self
      def is_promoted
        NIL_
      end
    end

    # ~ preconditions

    attr_reader :preconditions

    class << self

      def resolve_precondition_controller_identifer_array

        i_a = precondition_controller_i_a_
        x = persist_to

        if i_a

          a = i_a.map do | sym |
            Concerns_::Identifier.via_symbol  sym
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

      def precondition_for action, id, box, & oes_p
        id = @model_class.persist_to
        if id

          # assume this is an "ordinary" business silo with collection and so
          # its precondition *is* the collection. we could also place a dummy
          # value here and let the entity fetch the d.s from the box itself.

          box.fetch id.full_name_symbol
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

    # ~ as instance

    def initialize boundish, & oes_p  # #note-180 do not set error count here

      @on_event_selectively = oes_p or self._WHY
      @kernel = boundish.to_kernel
      @kernel.do_debug and @kernel.debug_IO.
        puts ">> >> >> >> MADE #{ name.as_slug } CTRL"
    end

    # ~~ dup-like and dup-related

    def new_via_iambic x_a
      dup.__init_duplication_via_iambic x_a
    end

    def initialize_copy _otr  # when dup is called (above)
      @property_box = @property_box.dup
    end

    protected def __init_duplication_via_iambic x_a

      # (for now we don't go thru normalization - but we might one day)

      x_a.each_slice 2 do  | k, x |
        @property_box.set k, x
      end

      self
    end

    # ~ the edit session API  (all :#public-API :#hook-in)

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

      Concerns__::Edit_Session.new_first_session_pair formal_properties
    end

    def subsequent_edit_shell

      Concerns__::Edit_Session.new_subsequent_session_pair formal_properties
    end

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

    # ~ persistence

    class << self

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
          Concerns_::Identifier.via_symbol sym
        end

        ACHIEVED_
      end

      attr_reader :_persist_to_sym

      def persist_to= sym
        @_persist_to_sym = sym
      end
    end

    attr_reader :came_from_persistence

    # ~ properties

    def to_even_iambic  # :+#public-API

      y = []
      st = to_qualified_knownness_stream_

      begin
        kn = st.gets
        kn or break
        _x = if kn.is_known
          kn.value_x
        end
        y.push kn.name_symbol, _x
        redo
      end while nil

      y
    end

    def to_pair_stream_for_persist  # :+public-API
      to_qualified_knownness_stream_
    end

    def property_value_via_property prp  # :+#public-API (limited but varied use)

      knownness_via_property_( prp ).value_x
    end

    def normalize_property_value_via_normal_entity prp, ent, & oes_p

      normal_x = ent.property_value_via_symbol prp.name_symbol
      mine_x = property_value_via_symbol prp.name_symbol

      if normal_x != mine_x

        @property_box.replace prp.name_symbol, normal_x

        maybe_send_event :info, :normalized_value do

          __build_normalized_value_event normal_x, mine_x, prp
        end
      end
    end

    def __build_normalized_value_event normal_x, mine_x, prp

      Callback_::Event.inline_OK_with(
        :normalized_value,
        :prop, prp,
        :previous_x, mine_x,
        :current_x, normal_x
      ) do | y, o |

        y << "using #{ ick o.current_x } for #{ par o.prop } #{
         }(inferred from #{ ick o.previous_x })"
      end
    end

    def property_value_via_symbol i  # ( was #note-120 )
      @property_box.fetch i
    end

    def properties
      @property_box or fail "no prop box for #{ self.class }"
    end

  private

    def as_entity_actual_property_box_
      @property_box
    end

    def primary_box__
      @property_box
    end

    def any_secondary_box__
      @parameter_box
    end

 public

    # ~ event receiving & sending

    def accept_selective_event_listener__ x
      @__HESVC_p__ = nil
      @on_event_selectively = x ; nil
    end

    # ~ the stack

    def silo
      @silo ||= __produce_silo
    end

    def __produce_silo
      @kernel.silo_via_identifier self.class.node_identifier
    end

    # ~ flyweigthing

    class << self

      def new_flyweight kernel, & oes_p

        me = self
        edit_entity_directly kernel, oes_p do
          @property_box = Model_::Concerns__::Flyweight::Property_Box.new me
        end
      end
    end

    # ~ this facility

    class << self

      def make_common_properties & edit_p
        common_properties_class.new entity_enhancement_module, & edit_p
      end

      def make_common_common_properties & edit_p
        common_properties_class.new common_entity_module, & edit_p
      end
    end

    class Common_Properties___ < ::Module

      def initialize entity_mod, & sess_p

        @_array = -> do
          a = @_box[].to_value_stream.to_a.freeze
          @_array = -> { a }
          a
        end

        @_box = -> do
          @_did_flush || @_flush[]
          bx = @_properties_p[]
          @_box = -> { bx }
          bx
        end

        @_properties_p = -> do
          self.properties
        end

        @_did_flush = false
        @_flush = -> do
          @_did_flush = true
          @_flush = nil
          __init_and_edit_entity_module entity_mod, & sess_p
          NIL_
        end
      end

      def has_name sym
        @_box[].has_name sym
      end

      def at * sym_a
        bx = @_box[]
        sym_a.map do | sym |
          bx.fetch sym
        end
      end

      def [] sym
        @_box[][ sym ]
      end

      def fetch sym, & p
        @_box[].fetch sym, & p
      end

      def array
        @_array[]
      end

      def to_value_stream
        @_box[].to_value_stream
      end

      def box
        @_box[]
      end

      def entity_property_class
        if ! @_did_flush
          @_flush[]
        end
        self::Property
      end

      def set_properties_proc & p  # if you are making a derivative collection
        @_did_flush = true
        @_flush = nil
        @_properties_p = p
        self
      end

      def __init_and_edit_entity_module entity_mod, & sess_p

        # [#xx-0011]
        _sess = Cmn_Prps_Session___.new self, entity_mod
        sess_p[ _sess ]
        NIL_
      end

    end

    class Cmn_Prps_Session___

      def initialize empty_module, extmod

        @_p = -> x_a, & edit_p do
          @_p = nil

          sess = Home_::Entity::Session.new
          sess.arglist = x_a
          sess.block = edit_p
          sess.client = empty_module
          sess.extmod = extmod
          sess.execute
        end
      end

      def edit_common_properties_module * a, & edit_p

        @_p[ a, & edit_p ]
      end
    end

    Model_ = self
  end
end
