module Skylab::Brazen

# ===( SNIP
  ActionToolkit = ::Class.new Home_::Nodesque::Node  # :[#024] (and see)
  class ActionToolkit
    # (actually see bottom of file)

    mtk = -> { ::Skylab::Zerk::MicroserviceToolkit }  # it is assumed
    MTk__ = mtk

    BoundCall_of_Operation_via = -> microservice_invo, oper_branch do

      act = ParseOperator_via[ microservice_invo, oper_branch ]
      if act
        _ref = act.mixed_business_value
        _ref.bound_call_of_operator_via_invocation microservice_invo
      end
    end

    # ==

    ParseOperator_via = -> microservice_invo, oper_branch do

      mtk[]::ParseArguments_via_FeaturesInjections.define do |o|

        o.argument_scanner = microservice_invo.invocation_resources.argument_scanner

        o.add_operators_injection_by do |inj|

          inj.operators = oper_branch
          inj.injector = :_no_injector_from_BR_
        end
      end.parse_operator
    end

    # === (the next three or so magnets are the sole implementors of
    #      [#062] "association injection and related" (see).)

    # ==

    class BoundCall_of_Operation_with_Definition < Common_::MagneticBySimpleModel

      # #open [#tm-032.2] now that this is a magnetic and not a proc,
      # refactor [tm] to be not redundant with here and DRY it up.
      # then EDIT this message in the next paragraph:
      #
      # (for now, if you want your own action grammar you'll have to
      # copy-paste-modify such a function, as [tm] does)

      # ("action" and "operation" are the same thing in different dialects.)

      # the action's `definition` method produces an array of primitives.
      # parse this with the appropriate grammar to produce a stream of
      # "items" whose each item is a name-value pair, the name being a
      # symbol from the grammar and the item being the corresponding
      # business value (e.g structure) that was parsed.
      #
      # (note that all the grammatical symbol names end in `*_BR_` to make
      # it clear that they "live" in this sidesystem (and indeed this file).)
      #
      # some of these structures are associations (i.e formal parameters).
      # we want to produce a stream that is is only of the associations (so
      # a map-reduce). but also: one special kind of item is itself a stream
      # of more associations (so a map-expand) (and this does not recurse).

      class << self
        def call op
          call_by do |o|
            o.operation = op
          end
        end
        alias_method :[], :call
      end  # >>

      def initialize
        @customize_normalization_by = nil
        @inject_definitions_by = nil
        super
        @action_grammar = Action_grammar___[]  # ..
      end

      attr_writer(
        :customize_normalization_by,
        :inject_definitions_by,
        :invocation_or_resources,
        :operation,
      )

      def execute

        __read_injections

        __init_association_stream

        if __normalize

          __inject_assignments

          # (downgrade false to nil)
          Common_::BoundCall.by( & @operation.method( :execute ) )
        end
      end

      def __normalize
        if __normalize_declaratives
          __normalize_imperatives
        end
      end

      def __normalize_imperatives
        a = remove_instance_variable :@_ad_hoc_normalizations
        if a
          __do_normalize_ad_hoc_normalizations a
        else
          ACHIEVED_
        end
      end

      def __do_normalize_ad_hoc_normalizations a
        ok = ACHIEVED_ ; op = @operation ; rsx = _invocation_resources
        a.each do |p|
          ok = p[ op, rsx ]
          ok || break
        end
        ok
      end

      def __normalize_declaratives

        _ok = MTk__[]::Normalization.call_by do |o|

          # main input payloads -
          o.association_stream_newschool = remove_instance_variable :@__association_stream
          o.entity_nouveau = @operation

          # behavior -
          o.will_nilify
            # (this option itself is cosmetic - without it only warnings.
            # however its side effect is to make every association "extroverted"
            # so that they are all traversed. changing this might mean death.)

          # how expressions are produced -
          o.attribute_lemma_symbol = :primary
          o.did_you_mean_map_by_symbol = :prim

          p = remove_instance_variable :@customize_normalization_by
          if p
            p[ o ]
          end
        end

        _ok  # hi. #todo
      end

      def __init_association_stream

        # [#011]: this one experimental feature
        if @operation.instance_variable_defined? :@_associations_
          _h = @operation.instance_variable_get :@_associations_
        end

        @__association_stream = AssociationStream_via_Definition___.call_by do |o|

          o.remove_these_and_add_these = remove_instance_variable :@_removes_adds

          o.write_associations_into_this_hash = _h

          o.definition_array = @operation.definition
          o.action_grammar = @action_grammar
        end
        NIL
      end

      def __read_injections
        p = remove_instance_variable :@inject_definitions_by
        if p
          __do_process_injections p
        else
          @_ad_hoc_normalizations = nil
          @_injected_assignments = nil
          @_removes_adds = nil
        end
      end

      def __do_process_injections p

        @_ad_hoc_normalizations = nil  # might add none
        @_remove_these = nil
        @_add_these = nil
        @_injected_assignments = nil
        p[ self ]  # :#spot1.1
        @_removes_adds = [
          remove_instance_variable( :@_remove_these ),
          remove_instance_variable( :@_add_these ),
        ]  # NOTE both elements above might be nil. consumer beware
        NIL
      end

      # -- for above

      def inject_ad_hoc_normalization & p
        ( @_ad_hoc_normalizations ||= [] ).push p ; nil
      end

      def inject_association_via_definition * sym_a
        _gi = @action_grammar.DEREFERENCE_INJECTION :_parameter_BR_
        _scn = Scanner_[ sym_a ]
        _asc = _gi.gets_one_item_via_scanner_fully _scn
        inject_association _asc
      end

      def deinject_association k
        ( @_remove_these ||= [] ).push k ; nil
      end

      def inject_association asc
        ( @_add_these ||= [] ).push asc ; nil
      end

      def assign k, & p
        ( @_injected_assignments ||= [] ).push [ p, k ] ; nil
      end

      # --

      def __inject_assignments
        a = remove_instance_variable :@_injected_assignments
        a and __process_injected_assignments a
      end

      def __process_injected_assignments a

        # EXPERIMENTAL details

        rsx = _invocation_resources
        op = @operation

        a.each do |(p, k)|
          _x = p[ rsx, op ]
          op._simplified_write_ _x, k
        end

        NIL
      end

      def _invocation_resources
        pair = @invocation_or_resources
        x = pair.value
        case pair.name_symbol
        when :_invocation_PL_ ; x.invocation_resources
        when :_invocation_resources_PL_ ; x
        else ; never
        end
      end
    end

    # ==

    class AssociationStream_via_Definition___ < Common_::MagneticBySimpleModel

      # (skip over non-association parsed items, like the description proc)

      def initialize
        @inject_definitions_by = nil
        super
      end

      attr_writer(
        :action_grammar,
        :definition_array,
        :remove_these_and_add_these,
        :write_associations_into_this_hash,
      )

      def execute

        remove_these, add_these = remove_instance_variable :@remove_these_and_add_these

        if remove_these
          pool = ::Hash[ remove_these.map { |k| [k, true] } ]
        end

        st = AssociationStream_via_Definition_PURELY_.call_by do |o|

          if add_these
            o.inject_these_associations_at_the_end = add_these
          end

          if remove_these  # (after `add_these` above)
            o.at_end_of_stream_also_do_this do
              if pool.length.nonzero?
                self._COVER_ME__items_to_remove_not_found__
              end
              NOTHING_
            end
          end

          o.definition_array = remove_instance_variable :@definition_array
          o.action_grammar = remove_instance_variable :@action_grammar
        end

        if remove_these
          st = __do_the_pool_based_reduction pool, st
        end

        h = remove_instance_variable :@write_associations_into_this_hash
        if h
          st.map_by do |asc|
            h[ asc.name_symbol ] = asc
            asc
          end
        else
          st  # [gi]
        end
      end

      def __do_the_pool_based_reduction pool, st
        st.reduce_by do |asc|
          _yes = pool.delete asc.name_symbol
          ! _yes
        end
      end
    end

    # ==

    class AssociationStream_via_Definition_PURELY_ < Common_::MagneticBySimpleModel

      def initialize
        @_at_end_of_stream_queue_array = nil
        super
        a = remove_instance_variable :@_at_end_of_stream_queue_array
        if a
          @_at_end_of_stream_queue_scanner = Scanner_[ a ]
          @_at_end_of_stream = :__at_end_of_stream_shift_queue
        else
          @_at_end_of_stream = :_at_end_of_stream_result_in_nothing
        end
      end

      def inject_these_associations_at_the_end= asc_a
        at_end_of_stream_also_do_this do
          _stream_over_each_item_then_do_this asc_a do
            send @_at_end_of_stream
          end
        end
      end

      def at_end_of_stream_also_do_this & p
        ( @_at_end_of_stream_queue_array ||= [] ).push p ; nil
      end

      attr_writer(
        :action_grammar,
        :definition_array,
      )

      def execute
        @_gets = :__gets_initially
        Common_.stream do
          send @_gets
        end
      end

      def __gets_initially
        _defn_a = remove_instance_variable :@definition_array
        @_qualified_item_stream = @action_grammar.stream_via_array _defn_a
        @_gets = :_gets_main
        send @_gets
      end

      def _gets_main
        begin
          qual_item = @_qualified_item_stream.gets
          unless qual_item
            x = send @_at_end_of_stream
            break
          end
          case qual_item.injection_identifier
          when :_parameter_BR_
            x = qual_item.item
            break
          when :_parameTERS_BR_
            x = __expand qual_item
            break
          when :_description_BR_
            redo
          end
          never
        end while above
        x
      end

      def __expand qual_item

        _stream_over_each_item_then_do_this qual_item.item do
          send( @_gets = :_gets_main )
        end
      end

      def _stream_over_each_item_then_do_this item_a, & after

        len = item_a.length
        len.zero? && self._COVER_ME__readme__just_call_the_proc__95_percent_sure_its_fine__  # #todo
        last = len - 1
        @__stream = Common_::Stream.via_times len do |d|
          if last == d
            remove_instance_variable :@__stream
            @__yikes = after
            @_gets = :__gets_via_yikes
          end
          item_a.fetch d
        end
        send( @_gets = :__gets_via_stream )
      end

      def __gets_via_stream
        @__stream.gets
      end

      def __gets_via_yikes
        remove_instance_variable( :@__yikes ).call
      end

      def __at_end_of_stream_shift_queue
        p = @_at_end_of_stream_queue_scanner.gets_one
        if @_at_end_of_stream_queue_scanner.no_unparsed_exists
          remove_instance_variable :@_at_end_of_stream_queue_scanner
          @_at_end_of_stream = :_at_end_of_stream_result_in_nothing
        end
        p[]
      end

      def _at_end_of_stream_result_in_nothing
        NOTHING_
      end
    end

    # ==

    Action_grammar___ = Lazy_.call do

      # this is a minimal, default grammar for the metadata of actions
      # which (in this minimal grammar) provisions for a description
      # proc for the action and the modeling of its zero or more parameters..
      # apps that want to do fancy things like [tm] can inject custom
      # grammars instead.

      _param_gi = MTk__[]::EntityKillerParameter.grammatical_injection

      _g = Home_.lib_.parse_lib::IambicGrammar.define do |o|

        o.add_grammatical_injection :_description_BR_, DESCRIPTION___

        o.add_grammatical_injection :_parameter_BR_, _param_gi

        o.add_grammatical_injection :_parameTERS_BR_, PARAMETERS___
      end

      _g  # hi. #todo
    end

    # ~

    module DESCRIPTION___ ; class << self

      # (the grammatical element for modeling the description of an action)

      def is_keyword k
        :description == k
      end

      def gets_one_item_via_scanner scn
        scn.advance_one ; scn.gets_one
      end
    end ; end

    # ~

    module PARAMETERS___ ; class << self

      # (the grammatical element for specifying the injection of an array
      # (or maybe stream) of several parameters (already parsed) into the
      # action definition.)

      def is_keyword k
        :properties == k  # (legacy name)
      end

      def gets_one_item_via_scanner scn
        scn.advance_one ; scn.gets_one
      end
    end ; end

    # ~
    # ~
  end

# ===)

  class ActionToolkit < Home_::Nodesque::Node  # see [#024]

    # -- Actionability - identity in & navigation of the ractive model

    class << self

      def build_unordered_index_stream & _

        # by default, (and for you always):

        if is_promoted
          # then you do not appear at this level
          NIL_
        else
          # it's just you
          Common_::Stream.via_item self
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

      __accept_selective_listener_proc oes_p
    end

    def __say_not_kernel k
      "update interface: should be kernel - #{ k.class }"   # #todo
    end

    # -- Invocation ( various means ) --

    def bound_call_against_argument_scanner_and_mutable_box st, bx

      @argument_box = bx

      _bound_call_after do
        process_argument_scanner_fully st
      end
    end

    def bound_call_against_argument_scanner st

      _bound_call_after do
        process_argument_scanner_fully st
      end
    end

    def bound_call_against_box box

      _bound_call_after do
        Home_::Actionesque::Input_Adapters::Via_value_box[ self, box ]
      end
    end

    attr_writer :argument_scanner_  # hax only (like above)

    def _bound_call_after

      @argument_box ||= Common_::Box.new

      ok = yield
      if ok
        via_arguments_produce_bound_call
      else
        Common_::BoundCall.via_value ok
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

      @argument_box = Common_::Box.new

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

      # expose the moment between `process_argument_scanner_fully` and `normalize`

      # when we call the user's `produce_result` we must have fulfilled
      # any preconditions. to fulfill preconditions may require that we
      # have a complete, normal set of arguments (i.e that defaults are
      # applied and required's may be assumed (i.e that `normalize` was
      # called). in order to normalize we need to have parsed the arguments.

      ok = normalize
      ok &&= __resolve_preconditions
      if ok
        Common_::BoundCall.via_receiver_and_method_name self, :produce_result
      else
        Common_::BoundCall.via_value ok
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

      bx = Common_::Box.new
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

        bx.add sym, Common_::QualifiedKnownness.
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

        h_[ k ] = Common_::QualifiedKnownKnown.via_value_and_association(
          h.fetch( k ), fo.fetch( k ) )
      end

      Common_::Box.via_integral_parts a_, h_
    end

    def qualified_knownness_of sym

      had = true
      x = @argument_box.fetch sym do
        had = false
      end

      Common_::QualifiedKnownness.via_value_and_had_and_association(
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

    def set_argument_scanner__ x
      @_argument_scanner_ = x
    end

    def remove_argument_scanner__
      remove_instance_variable :@_argument_scanner_
    end

    def when_after_process_iambic_fully_stream_has_content scn

      _ev = Home_.lib_.fields::Events::Extra.with(
        :unrecognized_token, scn.head_as_is,
      )
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

      Common_::Event.inline_not_OK_via_mutable_iambic_and_message_proc x_a, msg_p
    end

    def build_OK_event_with * x_a, & msg_p

      Common_::Event.inline_OK_via_mutable_iambic_and_message_proc x_a, msg_p
    end

    # -- Event receiving --

  public

    def __accept_selective_listener_proc oes_p  # ..

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

      class Emission_Interpreter____ < Common_::Emission::Interpreter

        def __expression__ i_a, & x_p  # this is [#023.A].
          _ :__receive_expression, i_a, & x_p
        end

        def __data__ i_a, & x_p
          _ :__receive_data_emission, i_a, & x_p
        end

        def __conventional__ i_a, & x_p
          _ :receive_conventional_emission, i_a, & x_p
        end

        new.freeze
      end
    end

    def receive_conventional_emission i_a, & ev_p

      @_upstream_event_handler.call( * i_a ) do

        _ev = if ev_p
          ev_p[]
        else
          Common_::Event.inline_via_normal_extended_mutable_channel i_a
        end

        Common_::Event::Via_signature[ name, _ev ]
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

      Common_::Event.inline_neutral_with _term_chan do | y, _o |

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
# #history-A.1: first injection of post-[br] distillation
# :+#tombstone: to_trio_stream (`to_qualified_knownness_stream`)
