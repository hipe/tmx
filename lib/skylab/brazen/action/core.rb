module Skylab::Brazen

  class Model

  class Action  # see [#024]

    class << self

      # ~ model API ancillaries & adjunctives

      # ~~ description & name

      def name_function_class
        Action_Name_Function__
      end

      attr_accessor :description_block

      # ~~ inflection

      def custom_action_inflection
        NIL_
      end

      def process_some_customized_inflection_behavior upstream
        Process_customized_action_inflection_behavior__.new( upstream, self ).execute
      end

      # ~~ placement

      attr_accessor :after_name_symbol

      private def after sym  # experimental alternative to the iambic DSL
        @after_name_symbol = sym
      end

      attr_accessor :is_promoted

      # ~~ preconditions

      attr_accessor :precondition_controller_i_a_

      def preconditions
        @__did_resolve_pcia ||= __resolve_precondition_controller_identifer_a
        @preconditions
      end

      def __resolve_precondition_controller_identifer_a
        @preconditions = if precondition_controller_i_a_
          @precondition_controller_i_a_.map do |i|
            Node_Identifier_.via_symbol i
          end
        else
          mc = model_class
          if mc
            if mc.respond_to? :preconditions
              mc.preconditions
            end
          end
        end
        true
      end

      # ~~ statics and/or defaults

      def is_actionable
        true
      end

      def is_branch  # 1 of 2
        false
      end

      def properties  # default is no properties
        NIL_
      end

      def any_property_via_symbol _
        NIL_
      end

      # ~ custom internal invocation interface

      def edit_and_call boundish, oes_p, & edit_p  # experimental
        new( boundish, & oes_p ).__edit_and_call( & edit_p )
      end

    private

      # ~ the common mutation inteface (defining an action)

      def edit_entity_class * x_a, & edit_p  # if you are here the class is not yet initted
        entity_module.call_via_client_class_and_iambic self, x_a, & edit_p
      end

      def entity_module
        model_class.superclass.const_get :Entity, false
      end

    public

      def model_class
        name_function.parent
      end
    end  # >>

    extend Brazen_.name_library.name_function_proprietor_methods
    NAME_STOP_INDEX = 2  # sl br models

    # [#013]:#note-A the below order

    include Callback_::Actor.methodic_lib.polymorphic_processing_instance_methods

    include Brazen_::Entity::Instance_Methods

    Brazen_.event.selective_builder_sender_receiver self

    include Interface_Element_Instance_Methods___

    def initialize boundish, & oes_p

      oes_p or raise ::ArgumentError

      @formal_properties = nil
      @preconditions = nil
      @kernel = boundish.to_kernel

      accept_selective_listener_proc oes_p
    end

    def accept_selective_listener_proc oes_p  # name might change to expose [ca]

      accept_selective_listener_via_channel_proc( -> i_a, & ev_p do

        receive_uncategorized_emission oes_p, i_a, & ev_p

      end )
    end

    def receive_uncategorized_emission oes_p, i_a, & x_p  # #note-100

      # this is :[#023]: (still experimental) `expression` as a level-2
      # channel name has the following magic treatment

      if :expression == i_a[ 1 ]

        __maybe_emit_expression oes_p, i_a, & x_p

      else

        maybe_emit_wrapped_or_autovivified_event oes_p, i_a, & x_p
      end
    end

    def maybe_emit_wrapped_or_autovivified_event oes_p, i_a, & ev_p

      oes_p.call( * i_a ) do

        _ev = if ev_p
          ev_p[]
        else
          Callback_::Event.inline_via_normal_extended_mutable_channel i_a
        end

        Callback_::Event.wrap.signature name, _ev
      end
    end

    # ~ begin experimental [#023] feature

    def __maybe_emit_expression oes_p, i_a, & msg_p

      first = i_a.first
      rest = i_a[ 2 .. -1 ]

      oes_p.call first, * rest do

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

      build_neutral_event_with _term_chan do | y, _o |

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

    # ~ end

  public

    def bound_call_against_polymorphic_stream_and_mutable_box st, bx

      _bound_call_against bx do
        process_polymorphic_stream_fully st
      end
    end

    def bound_call_against_polymorphic_stream st

      # meet any preconditions before calling the user's `produce_result`.
      # to meet preconditions we have to parse the iambic stream. to parse
      # the iambic stream we have to call `normalize`.

      _bound_call_against do
        process_polymorphic_stream_fully st
      end
    end

    def bound_call_against_box box

      # exactly as above

      _bound_call_against do
        __process_box_as_polymorphic_stream_fully box
      end
    end

    def _bound_call_against bx=Box_.new

      @argument_box = bx
      ok = yield
      if ok
        via_arguments_produce_bound_call
      else
        Callback_::Bound_Call.via_value ok
      end
    end

    # ~ experiment: is it worth it hacking external API actions for internal calls? [tm]

    def __edit_and_call & edit_p  # in the spirit of `<model class>.edit`

      first_edit( & edit_p )

      bc = via_arguments_produce_bound_call
      bc and begin
        bc.receiver.send bc.method_name, * bc.args
      end
    end

    def process_polymorphic_stream_fully_ x
      process_polymorphic_stream_fully x
    end

    # (end experiment)

    def polymorphic_writer_method_name_passive_lookup_proc  # #hook-in to [cb]

      # bend [cb] methodic to accomodate [#046] mutable formal properties

      formals = formal_properties

      if formals
        __polymorphic_writer_method_name_passive_lookup_proc_via_formals formals
      else
        -> _ { }  # MONADIC_EMPTINESS_
      end
    end

    def __polymorphic_writer_method_name_passive_lookup_proc_via_formals formals

      cls = self.class

      -> sym do
        prp = formals[ sym ]
        if prp
          if cls.method_defined? prp.polymorphic_writer_method_name  # not private - this is not actor
            prp.polymorphic_writer_method_name
          else
            @__last_formal_property__ = prp
            # either this hack or duplicate actor's logic
            :__via_last_formal_property_process_iambic_argument
          end
        end
      end
    end

    def __via_last_formal_property_process_iambic_argument
      prp = @__last_formal_property__
      if prp.takes_argument
         @argument_box.add prp.name_symbol, gets_one_polymorphic_value
      else
        @argument_box.add prp.name_symbol, true
      end
      KEEP_PARSING_
    end

    def via_arguments_produce_bound_call  # :+#public-API [ts]

      # expose the moment between `process_polymorphic_stream_fully` and `normalize`

      ok = normalize
      ok &&= __resolve_preconditions
      if ok
        Callback_::Bound_Call.via_receiver_and_method_name self, :produce_result
      else
        Callback_::Bound_Call.via_value ok
      end
    end

  private

    def __resolve_preconditions

      # the [#048] preconditions "pipeline" starts here, from the action.

      a = _formal_preconditions

      if a && a.length.nonzero?
        __resolve_preconditions_via_formal_preconditions a
      else
        ACHIEVED_
      end
    end

    def __resolve_preconditions_via_formal_preconditions a

      oes_p = handle_event_selectively

      bx = Model_::Preconditions_::Produce_Box.new(
        a,  # the identifiers for silos i depend on
        @preconditions,  # any starting box
        model_class.node_identifier,  # my identifier
        self,  # the action
        @kernel,
        & oes_p ).produce_box

      bx and begin
        @preconditions = bx
        ACHIEVED_
      end
    end

  public

    # ~ accessors for arguments & related experimentals

    def to_full_trio_box

      bx = Callback_::Box.new
      h = @argument_box.h_
      st = formal_properties.to_stream
      prp = st.gets

      while prp
        sym = prp.name_symbol
        had = true
        x = h.fetch sym do
          had = false
          nil
        end

        bx.add sym, Callback_::Trio.
          via_value_and_had_and_property( x, had, prp )

        prp = st.gets
      end

      bx
    end

    def to_trio_box_except__ * i_a  # [cu]

      fo = formal_properties
      h = @argument_box.h_
      a_ = @argument_box.a_ - i_a
      h_ = {}

      a_.each do | k |

        h_[ k ] = Callback_::Trio.via_value_and_property(
          h.fetch( k ), fo.fetch( k ) )
      end

      Callback_::Box.allocate.init a_, h_
    end

    def to_trio_stream

      fp = formal_properties
      a = @argument_box.a_ ; h = @argument_box.h_
      d = 0 ; len = a.length

      Callback_.stream do

        if d < len
          k = a.fetch d
          d += 1
          Callback_::Trio.via_value_and_property h.fetch( k ), fp.fetch( k )
        end
      end
    end

    def trio sym  # #hook-near model. may soften if needed.

      Callback_::Trio.via_value_and_property(
        @argument_box[ sym ],
        formal_properties.fetch( sym ) )
    end

    def argument_value sym
      @argument_box.fetch sym
    end

    def argument_box
      @argument_box
    end

    def formal_properties
      @formal_properties or init_formal_properties_ super
    end

    def init_formal_properties_ x
      a = _formal_preconditions
      if a and a.length.nonzero?
        a.each do | precon_id |
          otr = @kernel.silo_via_identifier( precon_id ).
            any_mutated_formals_for_depender_action_formals x
          otr and x = otr
        end
      end
      @formal_properties = x  # result
    end

    def _formal_preconditions  # maybe one day there will be mutable preconditions
      self.class.preconditions
    end

  private

    def primary_box
      @argument_box
    end

    def any_secondary_box  # #todo - after universal integration, get rid of secondary box of action
      Callback_::Box.the_empty_box
    end

    def actual_property_box
      @argument_box
    end

    def model_class
      self.class.model_class
    end

  public

    # ~ readers for collaborators

    def controller_nucleus  # :+#experimental
      [ @kernel, handle_event_selectively ]
    end

    def is_branch  # 2 of 2
      false  # for now, every action node is always a terminal (leaf) node
    end

    def kernel_
      @kernel
    end

    def preconditions  # for a collaborator that knows they exist & what they are
      @preconditions
    end

    # ~ writers for collaborators

    def accept_parent_node_ x
      @parent_node = x ; nil
    end

    def change_formal_properties x
      @formal_properties = x
      nil
    end

    # (was #note-160)

  end
  end
end
