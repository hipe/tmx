module Skylab::Brazen

  class Action < Home_::Nodesque::Node  # see [#024]

    # -- Actionability - identity in & navigation of the ractive model

    class << self

      def build_unordered_index_stream & _

        # by default, (and for you always):

        if is_promoted
          # then you do not appear at this level
          NIL_
        else
          # it's just you
          Callback_::Stream.via_item self
        end
      end

      def entity_enhancement_module

        if const_defined? :ENTITY_ENHANCEMENT_MODULE
          self::ENTITY_ENHANCEMENT_MODULE
        else
          silo_module.superclass.entity_enhancement_module
        end
      end

      def silo_module

        _any_parent = name_function.parent

        _any_parent || self  # if you are at top, you are at top.
      end

      def is_branch
        false
      end
    end  # >>

    def is_branch
      false
    end

    def silo_module
      self.class.silo_module
    end

    # -- Description, inflection & name --

    class << self

      def name_function_class
        Home_::Actionesque::Name
      end

      def name_function_lib
        Home_::Actionesque::Name
      end

      def custom_action_inflection  # #hook-in for that concern
        NIL_
      end
    end  # >>

    # -- Placement & visibilty --

    # -- As instance --

    def initialize kernel, & oes_p

      oes_p or raise ::ArgumentError
      kernel.respond_to? :reactive_tree_seed or raise ::ArgumentError, __say_not_kernel( kernel )


      @formal_properties = nil
      @preconditions = nil
      @kernel = kernel

      accept_selective_listener_proc oes_p
    end

    def __say_not_kernel k
      "update interface: should be kernel - #{ k.class }"   # #todo
    end

    # -- Invocation ( various means ) --

    def bound_call_against_polymorphic_stream_and_mutable_box st, bx

      @argument_box = bx

      _bound_call_after do
        process_polymorphic_stream_fully st
      end
    end

    def bound_call_against_polymorphic_stream st

      _bound_call_after do
        process_polymorphic_stream_fully st
      end
    end

    def bound_call_against_box box

      _bound_call_after do
        Home_::Actionesque::Input_Adapters::Via_value_box[ self, box ]
      end
    end

    attr_writer :polymorphic_upstream_  # hax only (like above)

    def _bound_call_after

      @argument_box ||= Callback_::Box.new

      ok = yield
      if ok
        via_arguments_produce_bound_call
      else
        Callback_::Bound_Call.via_value ok
      end
    end

    attr_writer :argument_box  # hax only

    class << self

      def edit_and_call boundish, oes_p, & edit_p  # experimental
        new( boundish, & oes_p ).__edit_and_call( & edit_p )
      end
    end

    def __edit_and_call & edit_p  # in the spirit of `<model class>.edit`

      first_edit( & edit_p )

      bc = via_arguments_produce_bound_call
      bc and begin
        bc.receiver.send bc.method_name, * bc.args
      end
    end

    def first_edit & edit_p  # :+#public-API [tm]. cannot fail

      @argument_box = Callback_::Box.new

      if edit_p
        edit_p[ es = Edit_Session___.new ]
        mf, @preconditions = es.to_a  # nil ok on both.

        if mf
          formal_properties
          @formal_properties = @formal_properties.to_mutable_box_like_proxy  # might be same object
          mf[ @formal_properties ]
        end
      end
      nil
    end

    class Edit_Session___
      def initialize
        @fo = @pcns = nil
      end
      def preconditions x
        @pcns = x
      end
      def mutate_formal_properties & p
        @fo = p ; nil
      end
      def to_a
        [ @fo, @pcns ]
      end
    end

    def via_arguments_produce_bound_call  # :+#public-API [ts]

      # expose the moment between `process_polymorphic_stream_fully` and `normalize`

      # when we call the user's `produce_result` we must have fulfilled
      # any preconditions. to fulfill preconditions may require that we
      # have a complete, normal set of arguments (i.e that defaults are
      # applied and required's may be assumed (i.e that `normalize` was
      # called). in order to normalize we need to have parsed the arguments.

      ok = normalize
      ok &&= __resolve_preconditions
      if ok
        Callback_::Bound_Call.via_receiver_and_method_name self, :produce_result
      else
        Callback_::Bound_Call.via_value ok
      end
    end

    def normalize  # :[#.C].
      ACHIEVED_  # OK is the default. override or use entity lib to go nuts..
    end

    # -- Preconditions --

    class << self

      def resolve_precondition_controller_identifer_array

        @preconditions = if precondition_controller_i_a_

          @precondition_controller_i_a_.map do | sym |

            Home_::Nodesque::Identifier.via_symbol sym
          end

        else
          sm = silo_module
          if sm && sm.object_id != self.object_id
            if sm.respond_to? :preconditions
              sm.preconditions
            end
          end
        end
        ACHIEVED_
      end
    end  # >>

    def preconditions  # for a collaborator that knows they exist & what they are
      @preconditions
    end

    def receive_starting_preconditions bx
      @preconditions = bx
      nil
    end

    def __resolve_preconditions

      # the [#048] preconditions "pipeline" starts here, from the action.

      a = _formal_preconditions

      if a && a.length.nonzero?
        __resolve_preconditions_via_formal_preconditions a
      else
        ACHIEVED_
      end
    end

    def _formal_preconditions  # maybe one day there will be mutable preconditions
      self.class.preconditions
    end

    def __resolve_preconditions_via_formal_preconditions a

      oes_p = handle_event_selectively

      bx = Home_::Actionesque::Preconditions::Produce_Box.new(
        a,  # the identifiers for silos i depend on
        @preconditions,  # any starting box
        silo_module.node_identifier,  # my identifier
        self,  # the action
        @kernel,
        & oes_p ).produce_box

      bx and begin
        @preconditions = bx
        ACHIEVED_
      end
    end

    # -- Properties ( name conventions express visibility for ALL methods )

    ## ~~ readers

    def to_full_qualified_knownness_box

      bx = Callback_::Box.new
      h = @argument_box.h_
      st = formal_properties.to_value_stream
      prp = st.gets

      while prp
        sym = prp.name_symbol
        had = true
        x = h.fetch sym do
          had = false
          nil
        end

        bx.add sym, Callback_::Qualified_Knownness.
          via_value_and_had_and_association( x, had, prp )

        prp = st.gets
      end

      bx
    end

    def to_qualified_knownness_box_proxy
      Home_::Actionesque::Output_Adapters::Actual_Values_as_Box.new(
        @argument_box,
        formal_properties,
      )
    end

    def to_qualified_knownness_box_except__ * i_a  # [cu]

      fo = formal_properties
      h = @argument_box.h_
      a_ = @argument_box.a_ - i_a
      h_ = {}

      a_.each do | k |

        h_[ k ] = Callback_::Qualified_Knownness.via_value_and_association(
          h.fetch( k ), fo.fetch( k ) )
      end

      Callback_::Box.via_integral_parts a_, h_
    end

    def qualified_knownness_of sym

      had = true
      x = @argument_box.fetch sym do
        had = false
      end

      Callback_::Qualified_Knownness.via_value_and_had_and_association(
        x, had, formal_properties.fetch( sym ) )
    end

    def argument_value sym
      @argument_box.fetch sym
    end

    def argument_box
      @argument_box
    end

    ## ~~ writers ( for actual properties ( "values" ) ) & support

    def process_qualified_knownness_box_passively__ bx

      Home_::Actionesque::Input_Adapters::Via_qualified_knownness_box[ self, bx ]  # result is result
    end

    def set_polymorphic_upstream__ x
      @polymorphic_upstream_ = x
    end

    def remove_polymorphic_upstream__
      remove_instance_variable :@polymorphic_upstream_
    end

    def when_after_process_iambic_fully_stream_has_content st

      _a = [ st.current_token ]

      _ev = Callback_::Actor::Methodic::Build_extra_values_event[ _a ]

      receive_extra_values_event _ev
    end

    def receive_extra_values_event ev

      raise ev.to_exception
    end

    ## ~~ the formal properties

    class << self

      def properties  # default is no properties
        NIL_
      end
    end

    def formal_properties
      @formal_properties or init_formal_properties_ super
    end

    def change_formal_properties x  # :+#public-API (for collaborators)
      @formal_properties = x
      NIL_
    end

    def init_formal_properties_ pbx

      a = _formal_preconditions

      if a and a.length.nonzero?

        a.each do | precon_id |

          _silo = @kernel.silo_via_identifier precon_id

          otr = _silo.any_mutated_formals_for_depender_action_formals pbx

          if otr
            pbx = otr
          end
        end
      end

      @formal_properties = pbx  # result
    end

    ## ~~ related #hook-outs/in's

  private

    def primary_box__
      @argument_box
    end

    def any_secondary_box__
      NIL_
    end

    def as_entity_actual_property_box_
      @argument_box
    end

    # ( all below method & ivar names :+#public-API per name conv. )

    # -- Event sending --

    def maybe_send_event_via_channel i_a, & ev_p

      handle_event_selectively[ * i_a, & ev_p ]
    end

    def build_not_OK_event_with * x_a, & msg_p

      Callback_::Event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, msg_p
    end

    def build_OK_event_with * x_a, & msg_p

      Callback_::Event.inline_OK_via_mutable_iambic_and_message_proc x_a, msg_p
    end

    # -- Event receiving --

  public

    def accept_selective_listener_proc oes_p  # name might change to expose [ca]

      @_upstream_event_handler = oes_p

      @on_event_selectively = -> * i_a, & ev_p do

        receive_uncategorized_emission i_a, & ev_p
      end
      NIL_
    end

  private

    def receive_uncategorized_emission i_a, & x_p  # #note-100

      bc = Emission_interpreter___[][ i_a, & x_p ]

      send bc.method_name, * bc.args, & bc.block
    end

    Emission_interpreter___ = Lazy_.call do

      Require_emission_lib_[]

      class Emission_Interpreter____ < Emission_Interpreter_

        def __expression__ i_a, & x_p  # this is [#023.A].
          _ i_a, :__receive_expression, & x_p
        end

        def __data__ i_a, & x_p
          _ i_a, :__receive_data_emission, & x_p
        end

        def __conventional__ i_a, & x_p
          _ i_a, :receive_conventional_emission, & x_p
        end

        new.freeze
      end
    end

    def receive_conventional_emission i_a, & ev_p

      @_upstream_event_handler.call( * i_a ) do

        _ev = if ev_p
          ev_p[]
        else
          Callback_::Event.inline_via_normal_extended_mutable_channel i_a
        end

        Callback_::Event.wrap.signature name, _ev
      end
    end

    # ~ the map filter for [#023.B] `data`-style events

    def __receive_data_emission i_a, & x_p

      # for now, all the onus is on the client to handle these.

      @_upstream_event_handler.call( * i_a ) do
        x_p[]
      end
    end

    # ~ the map filter for [#023.A] `expression`-style events

    def __receive_expression i_a, & msg_p

      first = i_a.first
      rest = i_a[ 2 .. -1 ]

      @_upstream_event_handler.call first, * rest do

        # (because we have changed the signature of the potential event from
        #  being an expression to an event object we must modify the channel)

        send :"__build__#{ first }__event_via_expression", rest, & msg_p
      end
    end

    def __build__error__event_via_expression rest, & msg_p  # mutates `rest`

      # `rest` is a channel - don't encourage abuse by acccepting iambic
      # name-value pairs there. don't use simple expressions if you want
      # to include metadata in your event.

      _term_chan = _any_expr_chan( rest ) || :generic_error

      build_not_OK_event_with _term_chan do | y, _o |

        # (remember, this context right here is the expression agent)

        calculate y, & msg_p
      end
    end

    def __build__info__event_via_expression rest, & msg_p  # ditto

      _term_chan = _any_expr_chan( rest ) || :generic_info

      Callback_::Event.inline_neutral_with _term_chan do | y, _o |

        calculate y, & msg_p
      end
    end

    def __build__payload__event_via_expression rest, & msg_p  # ditto

      _term_chan = _any_expr_chan( rest ) || :generic_payload

      build_OK_event_with _term_chan do | y, _o |

        calculate y, & msg_p
      end
    end

    def _any_expr_chan i_a

      case i_a.length
      when 1..2  ; i_a.fetch 0
      when 3     ; i_a.fetch 2
      end
    end
  end
end
# :+#tombstone: to_trio_stream (`to_qualified_knownness_stream`)
