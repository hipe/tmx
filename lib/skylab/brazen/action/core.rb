module Skylab::Brazen

  class Action < Interface_Tree_Node_  # see [#024]

    # -- Concerns --

    # ~ actionability - identity in & navigation of the interface tree

    class << self

      def entity_enhancement_module

        if const_defined? :ENTITY_ENHANCEMENT_MODULE
          self::ENTITY_ENHANCEMENT_MODULE
        else
          model_class.superclass.entity_enhancement_module
        end
      end

      def is_actionable
        true
      end

      def is_branch
        false
      end

      def model_class
        name_function.parent
      end
    end  # >>

    def controller_nucleus  # :+#experimental
      [ @kernel, handle_event_selectively ]
    end

    def is_branch
      false
    end

    def model_class
      self.class.model_class
    end

    def accept_parent_node_ x
      @parent_node = x ; nil
    end

    # ~ description & inflection

    class << self

      def custom_action_inflection
        NIL_
      end

      def process_some_customized_inflection_behavior upstream
        Concerns__::Inflection.new( upstream, self ).execute
      end
    end

    # ~ name

    class << self

      def name_function_class
        Concerns__::Name
      end
    end

    NAME_STOP_INDEX = 2  # sl br models

    Autoloader_[ Concerns__ = ::Module.new, :boxxy ]

    class Concerns__::Name < Concerns_::Name

      def inflected_verb
        _inflection.inflected_verb
      end

      def verb_lexeme
        _inflection.verb_lexeme
      end

      def verb_as_noun_lexeme
        _inflection.verb_as_noun_lexeme
      end

      def _inflection
        @___inflecion ||= Brazen_::Concerns_::Inflection.for_action self
      end
    end

    # ~ placement & visibility

    class << self

      attr_accessor :is_promoted
    end

    # ~ as instance

    def initialize boundish, & oes_p

      oes_p or raise ::ArgumentError

      @formal_properties = nil
      @preconditions = nil
      @kernel = boundish.to_kernel

      accept_selective_listener_proc oes_p
    end

    # ~ invocation ( various means )

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
        Concerns__::Properties::Input::Via_value_box[ self, box ]
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

    def normalize
      ACHIEVED_  # OK is the default. override or use entity lib to go nuts
    end

    # ~ preconditions

    class << self

      def resolve_precondition_controller_identifer_array

        @preconditions = if precondition_controller_i_a_

          @precondition_controller_i_a_.map do | sym |

            Concerns_::Identifier.via_symbol sym
          end

        else
          mc = model_class
          if mc
            if mc.respond_to? :preconditions
              mc.preconditions
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

      bx = Brazen_::Concerns_::Preconditions::Produce_Box.new(
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

    # ~ properties ( name conventions express visibility for ALL methods )

    ## ~~ readers

    def to_full_trio_box

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
          via_value_and_had_and_model( x, had, prp )

        prp = st.gets
      end

      bx
    end

    def to_trio_box_proxy
      Concerns__::Properties::Output::Trio_Box_Proxy.
        new @argument_box, formal_properties
    end

    def to_trio_box_except__ * i_a  # [cu]

      fo = formal_properties
      h = @argument_box.h_
      a_ = @argument_box.a_ - i_a
      h_ = {}

      a_.each do | k |

        h_[ k ] = Callback_::Qualified_Knownness.via_value_and_model(
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
          Callback_::Qualified_Knownness.via_value_and_model h.fetch( k ), fp.fetch( k )
        end
      end
    end

    def argument_value sym
      @argument_box.fetch sym
    end

    def argument_box
      @argument_box
    end

    ## ~~ writers ( for actual properties ( "values" ) ) & support

    def process_trio_box_passively__ bx

      Concerns__::Properties::Input::Via_trio_box[ self, bx ]  # result is result
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

    module Concerns__::Properties
      Autoloader_[ Input = ::Module.new ]
      Autoloader_[ self ]
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

    # ~ event .. ( all method & ivar names :+#public-API per name conv. )

    ## ~~ sending

    def maybe_send_event_via_channel i_a, & ev_p

      handle_event_selectively[ * i_a, & ev_p ]
    end

    def build_not_OK_event_with * x_a, & msg_p

      Callback_::Event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, msg_p
    end

    def build_OK_event_with * x_a, & msg_p

      Callback_::Event.inline_OK_via_mutable_iambic_and_message_proc x_a, msg_p
    end

    ## ~~ receiving

  public

    def accept_selective_listener_proc oes_p  # name might change to expose [ca]

      @on_event_selectively = -> * i_a, & ev_p do

        receive_uncategorized_emission oes_p, i_a, & ev_p

      end
      NIL_
    end

  private

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
