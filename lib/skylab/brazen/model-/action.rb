module Skylab::Brazen

  class Model_

  class Action  # see [#024]

    class << self
    private

      # ~ mutators that define the action:

      def edit_entity_class * x_a, & edit_p  # if you are here the class is not yet initted
        entity_module.call_via_client_class_and_iambic self, x_a, & edit_p
      end

      def entity_module
        model_class.superclass.const_get :Entity, false
      end

      def after sym  # experimental alternative to the iambic DSL
        @after_name_symbol = sym ; nil
      end

    public

      # ~ exposures of adjunct & experimental algorithms

      def process_some_customized_inflection_behavior upstream
        Process_customized_action_inflection_behavior__.new( upstream, self ).execute
      end

      def edit_and_call boundish, oes_p, & edit_p
        new( boundish, & oes_p ).__edit_and_call( & edit_p )
      end

      # ~ reflection-like exposures for model API

      attr_accessor :after_name_symbol, :description_block,
        :is_promoted, :precondition_controller_i_a

      def custom_action_inflection
      end

      def is_actionable
        true
      end

      def is_branch
        false  # for now, every action node is always a terminal (leaf) node
      end

      def preconditions
        @__did_resolve_pcia ||= __resolve_precondition_controller_identifer_a
        @preconditions
      end

      def __resolve_precondition_controller_identifer_a
        @preconditions = if precondition_controller_i_a
          @precondition_controller_i_a.map do |i|
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

      def model_class
        name_function.parent
      end

      def name_function_class
        Action_Name_Function__
      end

      # ~ default #hook-outs for entity lib (default is no properties)

      def properties
        nil
      end

      def any_property_via_symbol _
        nil
      end

    end  # >>

    extend Brazen_.name_library.name_function_proprietor_methods
    NAME_STOP_INDEX = 2  # sl br models

    # [#013]:#note-A the below order

    include Callback_::Actor.methodic_lib.iambic_processing_instance_methods

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

    def __build__info__event_via_expression rest, & msg_p  # mutates `rest`

      # `rest` is a channel - don't encourage abuse by acccepting iambic
      # name-value pairs there. don't use simple expressions if you want
      # to include metadata in your event.

      _terminal_channel = rest.length.zero? ? :generic_info : rest.fetch( 0 )

      build_neutral_event_with _terminal_channel do | y, _o |

        # (remember, this context right here is the expression agent)

        calculate y, & msg_p
      end
    end

    # ~ end

  public

    def bound_call_against_iambic_stream st

      # meet any preconditions before calling the user's `produce_result`.
      # to meet preconditions we have to parse the iambic stream. to parse
      # the iambic stream we have to call `normalize`.

      _bound_call_against do
        process_iambic_stream_fully st
      end
    end

    def bound_call_against_box box

      # exactly as above

      _bound_call_against do
        __process_box_as_iambic_stream_fully box
      end
    end

    def __process_box_as_iambic_stream_fully bx  # experimental

      keep_parsing = true
      formals = formal_properties
      pxy = Value_As_Stream_Like_Proxy___.new
      @__methodic_actor_iambic_stream__ = pxy
      bx.each_pair do | k, x |

        prp = formals[ k ]
        if ! prp
          pxy.accept_current_token_ k
          when_after_process_iambic_fully_stream_has_content pxy
          keep_parsing = false
          break
        end

        if prp.takes_argument

          pxy.accept_current_token_ x
          keep_parsing = send prp.iambic_writer_method_name

        elsif x

          # the formal is a flag and the actual is true-ish. disregard what
          # the actual value is, in the interest of iambic isomorphism.

          pxy.clear
          keep_parsing = send prp.iambic_writer_method_name

        else

          # the formal is a flag and the actual is known but false-ish..
          # it's tempting to add the [ nil or false ] to the argument box,
          # but this is in violation of the iambic isomorphism

        end

        keep_parsing or break

      end
      @__methodic_actor_iambic_stream__ = nil
      keep_parsing
    end

    class Value_As_Stream_Like_Proxy___

      def current_token
        @p[]
      end

      def gets_one
        x = @p[]
        @p = nil
        x
      end

      def accept_current_token_ x
        @p = -> do
          x
        end ; nil
      end

      def clear
        @p = nil
      end
    end

    def _bound_call_against

      @argument_box = Box_.new
      ok = yield
      if ok
        via_arguments_produce_bound_call
      else
        Brazen_.bound_call.via_value ok
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

    def first_edit & edit_p  # :+#public-API [tm]. cannot fail

      @argument_box = Callback_::Box.new

      if edit_p
        edit_p[ es = Edit_Session__.new ]
        mf, @preconditions = es.to_a  # nil ok on both.

        if mf
          formal_properties
          @formal_properties = @formal_properties.to_mutable_box_like_proxy  # might be same object
          mf[ @formal_properties ]
        end
      end
      nil
    end

    def receive_starting_preconditions bx
      @preconditions = bx
      nil
    end

    def process_pair_box_passively bx  # wants to go up. #magnetic

      method_name_p = iambic_writer_method_name_passive_lookup_proc
      keep_parsing = true

      bx.each_pair do | k, single |
        m_i = method_name_p[ k ]
        m_i or next
        @__methodic_actor_iambic_stream__ = Gets_One_Value_Proxy___.new single.value_x
        keep_parsing = send m_i
        keep_parsing or break
      end

      keep_parsing
    end

    Gets_One_Value_Proxy___ = ::Struct.new :gets_one

    def process_iambic_stream_fully_ x
      process_iambic_stream_fully x
    end

    class Edit_Session__
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

    # (end experiment)

    def iambic_writer_method_name_passive_lookup_proc  # #hook-in to [cb]

      # bend [cb] methodic to accomodate [#046] mutable formal properties

      cls = self.class
      formals = formal_properties

      -> sym do
        prp = formals[ sym ]
        if prp
          if cls.method_defined? prp.iambic_writer_method_name  # not private - this is not actor
            prp.iambic_writer_method_name
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
         @argument_box.add prp.name_symbol, iambic_property
      else
        @argument_box.add prp.name_symbol, true
      end
      KEEP_PARSING_
    end

    def via_arguments_produce_bound_call  # :+#public-API [ts]

      # expose the moment between `process_iambic_stream_fully` and `normalize`

      ok = normalize
      ok &&= __resolve_preconditions
      if ok
        Brazen_.bound_call nil, self, :produce_result
      else
        Brazen_.bound_call.via_value ok
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
      _Trio = Trio__[]
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
        bx.add sym, _Trio.new( x, had, prp )
        prp = st.gets
      end
      bx
    end

    def to_trio_box_proxy
      Trio_Box_Proxy___.new @argument_box, formal_properties
    end

    class Trio_Box_Proxy___

      def initialize argument_box, formals
        @argument_box = argument_box
        @fo = formals
        @h = {}
      end

      def members ; [ :fo, :argument_box ] end

      attr_reader :fo, :argument_box

      def any_trueish k
        x = @argument_box[ k ]
        x and begin
          Trio__[].new x, true, @fo.fetch( k )
        end
      end

      def [] k
        fetch k do end
      end

      def fetch k, & p

        @h.fetch k do

          had_x = true
          x = @argument_box.fetch k do
            had_x = false
            nil
          end

          had_f = true
          f = @fo.fetch k do
            had_f = false
            nil
          end

          if had_f || had_x
            Trio__[].new x, had_x, f
          elsif p
            p[]
          else
            raise ::KeyError, "no formal or actual argument '#{ k }'"
          end
        end
      end

      def to_value_stream
        a = @argument_box.a_
        fo = @fo
        h = @argument_box.h_
        _Trio = Trio__[]

        Callback_::Stream.via_times a.length do | d |
          k = a.fetch d
          _Trio.new h.fetch( k ), true, fo.fetch( k )
        end
      end
    end

    def to_trio_box_except__ * i_a  # [cu]
      _Trio = Trio__[]
      fo = formal_properties
      h = @argument_box.h_
      a_ = @argument_box.a_ - i_a
      h_ = {}
      a_.each do | k |
        h_[ k ] = _Trio.new h.fetch( k ), true, fo.fetch( k )
      end
      Callback_::Box.allocate.init a_, h_
    end

    def to_trio_stream
      _Trio = Trio__[]
      fp = formal_properties
      a = @argument_box.a_ ; h = @argument_box.h_
      d = 0 ; len = a.length
      Callback_.stream do
        if d < len
          k = a.fetch d
          d += 1
          _Trio.new h.fetch( k ), true, fp.fetch( k )
        end
      end
    end

    def trio sym  # #hook-near model. may soften if needed.
      Trio__[].new(
        @argument_box[ sym ], true, formal_properties.fetch( sym ) )
    end

    Trio__ = -> do
      Callback_::Trio
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

    def accept_parent_node_ x
      @parent_node = x ; nil
    end

    def change_formal_properties x
      @formal_properties = x
      nil
    end

    def controller_nucleus  # :+#experimental
      [ @kernel, handle_event_selectively ]
    end

    def kernel_
      @kernel
    end

    def preconditions  # for a collaborator that knows they exist & what they are
      @preconditions
    end

    # (was #note-160)

    class Process_customized_action_inflection_behavior__

      def initialize * a
        @upstream, @cls = a
      end

      def execute
        @inflection = Customized_Action_Inflection__.new
        process_iambic_stream_passively @upstream
        acpt @inflection
      end

      include Callback_::Actor.methodic_lib.iambic_processing_instance_methods

    private

      def noun=
        parse :noun
      end

      def verb=
        parse :verb
      end

      def verb_as_noun=
        parse :verb_as_noun
      end

      def parse i
        x = @upstream.gets_one
        take_one x, i
        take_any_others i
      end

      def take_one x, i
        if x.respond_to? :id2name
          if :with_lemma == x
            @inflection.set_lemma @upstream.gets_one, i
          else
            @inflection.set_comb x, i
          end
        else
          @inflection.set_lemma x, i
        end
        KEEP_PARSING_
      end

      def take_any_others i
        while @upstream.unparsed_exists
          x = @upstream.current_token
          if x.respond_to? :ascii_only?
            @inflection.set_lemma @upstream.gets_one, i
          elsif :with_lemma == x
            @upstream.advance_one
            @inflection.set_lemma @upstream.gets_one, i
          else
            break
          end
        end
        KEEP_PARSING_
      end

      def acpt _ACTION_INFLECTION_
        @cls.send :define_singleton_method, :custom_action_inflection do
          _ACTION_INFLECTION_
        end
        KEEP_PARSING_
      end
    end

    class Customized_Action_Inflection__

      attr_reader :has_verb_exponent_combination, :has_verb_lemma,
        :verb_exponent_combination_i, :verb_lemma,

        :has_noun_exponent_combination, :has_noun_lemma,
        :noun_exponent_combination_i, :noun_lemma,

        :has_verb_as_noun_lemma,
        :verb_as_noun_lemma

      def set_lemma s, i
        instance_variable_set :"@has_#{ i }_lemma", true
        instance_variable_set :"@#{ i }_lemma", s ; nil
      end

      def set_comb i, i_
        instance_variable_set :"@has_#{ i_ }_exponent_combination", true
        instance_variable_set :"@#{ i_ }_exponent_combination_i", i ; nil
      end
    end

    class Action_Name_Function__ < Model_Name_Function_

      def inflected_verb
        inflection_kernel.inflected_verb
      end

      def verb_lexeme
        inflection_kernel.verb_lexeme
      end

      def verb_as_noun_lexeme
        inflection_kernel.verb_as_noun_lexeme
      end

    private
      def inflection_kernel
        @inflection_kernel ||= Model_::Inflection_Kernel__.for_action self
      end
    end

  end
  end
end
