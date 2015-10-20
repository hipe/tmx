module Skylab::Brazen

  class Model < Home_::Nodesque::Node  # read [#013]

    # -- Defining the model & producing entities  --

    class << self

      def make_action_making_actions_module  # writer

        factory = Home_::Actionesque::Factory.make(
          self,
          action_base_class,
          entity_enhancement_module )

        const_set :Factory___, factory
        factory.make_actions_module
      end

      def make_common_properties & edit_p
        Home_::Nodesque::Common_Properties.new entity_enhancement_module, & edit_p
      end

      def edit_entity kernel, oes_p, & edit_p

        new( kernel, & oes_p ).first_edit( & edit_p )
      end

      def entity_enhancement_module

        if const_defined? :ENTITY_ENHANCEMENT_MODULE
          self::ENTITY_ENHANCEMENT_MODULE
        else
          Home_::Modelesque::Entity
        end
      end

      def action_base_class
        Home_::Action
      end
    end  # >>

    # -- Actionability - identity in & navigation of the reactive model --

    class << self

      def build_unordered_selection_stream & x_p  # used by silos
        _unbounds_indexation.build_unordered_selection_stream( & x_p )
      end

      def build_unordered_index_stream & x_p
        _unbounds_indexation.build_unordered_index_stream( & x_p )
      end

      def build_unordered_real_stream & x_p
        _unbounds_indexation.build_unordered_real_stream( & x_p )
      end

      def _unbounds_indexation
        @___UI ||= build_unbounds_indexation_
      end

      def build_unbounds_indexation_
        Home_::Branchesque::Indexation.new(
          const_get( ACTIONS_CONST, false ),  # if any
          self,
        )
      end

      def is_branch
        true
      end
    end  # >>

    def to_unordered_selection_stream
      _via_unbounds_indexation :build_unordered_selection_stream
    end

    def to_unordered_real_stream
      _via_unbounds_indexation :build_unordered_real_stream
    end

    def _via_unbounds_indexation m
      unbounds_indexation_.send m, & @on_event_selectively
    end

    def unbounds_indexation_
      self.class._unbounds_indexation
    end

    def fast_lookup
      NIL_  # see others
    end

    def is_branch
      self.class.is_branch
    end

    # -- Description & inflection & name --

    class << self

      def node_identifier
        @__node_ID ||= Home_::Nodesque::Identifier.via_name_function name_function, self
      end

      def natural_key_string_property
        properties.fetch NAME_SYMBOL
      end

      def name_function_class
        Home_::Nodesque::Name
      end

      def name_function_lib
        Home_::Modelesque::Name
      end
    end  # >>

    def natural_key_string  # idiomatic [tm]
      @property_box.fetch NAME_SYMBOL
    end

    # -- Placement & visibility --

    # -- Preconditions --

    attr_reader :preconditions

    class << self

      def resolve_precondition_controller_identifer_array

        i_a = precondition_controller_i_a_
        x = persist_to

        if i_a

          a = i_a.map do | sym |
            Home_::Nodesque::Identifier.via_symbol sym
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

    private def entity_collection  # :+#public-API
      @preconditions.fetch self.class.persist_to.full_name_symbol
    end

    # -- As instance --

    def initialize kernel, & oes_p  # #note-180 do not set error count here

      kernel.respond_to? :unbound_models or raise ::ArgumentError, __say_etc( kernel )  # #todo - this is temporary

      @on_event_selectively = oes_p or self._WHY
      @kernel = kernel
      @kernel.do_debug and @kernel.debug_IO.
        puts ">> >> >> >> MADE #{ name.as_slug } CTRL"
    end

    def __say_etc k
      "update interface: should be kernel - #{ k.class }"
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

    # -- the Edit session API (all #public-API #hook-in) --

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

      Home_::Modelesque::Edit_Session.new_first_session_pair formal_properties
    end

    def subsequent_edit_shell

      Home_::Modelesque::Edit_Session.new_subsequent_session_pair formal_properties
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

    # ~ properties

    def to_even_iambic  # :+#public-API

      y = []
      st = to_qualified_knownness_stream_

      begin
        kn = st.gets
        kn or break
        _x = if kn.is_known_known
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

      qualified_knowness_via_association_( prp ).value_x
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

    # ~ the stack (silo, etc)

    def silo
      @silo ||= __produce_silo
    end

    def __produce_silo
      @kernel.silo_via_identifier self.class.node_identifier
    end

    def self.silo_daemon_class
      const_get Home_::Silo::DAEMON_CONST, false
    end

    # ~ flyweigthing

    class << self

      def new_flyweight kernel, & oes_p

        me = self
        _edit_entity_directly kernel, oes_p do
          @property_box = Home_::Modelesque::Flyweight::Property_Box.new me
        end
      end
    end

    # ~ this facility

    class << self

      def make_common_common_properties & edit_p
        c_ommon_properties_class.new common_entity_module, & edit_p
      end
    end

    # -- Persistence --

    class << self

      def unmarshalled kernel, oes_p, & edit_p  # produce an entity from pers.

        _edit_entity_directly kernel, oes_p do

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
          Home_::Nodesque::Identifier.via_symbol sym
        end

        ACHIEVED_
      end

      attr_reader :_persist_to_sym

      def persist_to= sym
        @_persist_to_sym = sym
      end
    end  # >>

    attr_reader :came_from_persistence

    ## -- internal support for concerns above

    def self._edit_entity_directly boundish, oes_p, & edit_p

      o = new boundish, & oes_p
      o.instance_exec( & edit_p )
      o
    end
  end
end
