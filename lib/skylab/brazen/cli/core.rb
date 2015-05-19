module Skylab::Brazen

  class CLI < ::Class.new ::Class.new  # see [#002]

    class << self

      def arguments
        CLI_::Action_Adapter_::Arguments
      end

      def expression_agent_class
        CLI_::Expression_Agent
      end

      def expression_agent_instance
        CLI_::Expression_Agent.instance
      end

      alias_method :new_top_invocation, :new
      def new * a
        new_top_invocation a, Brazen_.application_kernel_
      end

      def pretty_path x
        expression_agent_class.pretty_path x
      end
    end  # >>

    Top_Invocation__ = self

    Branch_Invocation__ = Top_Invocation__.superclass

    Invocation__ = Branch_Invocation__.superclass

    class Top_Invocation__

      def initialize a, ak
        @app_kernel = ak
        @env = nil
        @mod = ak.module
        @resources = Resources__.new a, @mod
        # (abstract base class "invocation" has no initialize method)
      end

      def members
        [ :application_kernel, :bound_action, * super ]
      end

      def receive_environment x  # experiment
        @env = x ; nil
      end

      def env_
        @env
      end

      def invoke argv

        if @resources.frozen?  # :+#experimental: subsequent invocation

          @resources = @resources.new argv
        else

          @resources.complete @env || ::ENV, argv
        end

        resolve_properties
        resolve_categorized_properties
        bc = _some_bound_call
        x = bc.receiver.send bc.method_name, * bc.args, & bc.block
        flush_any_invitations
        if x
          whn_result_is_trueish x
        else
          @exit_status
        end
      end

    public

      def bound_
        @app_kernel
      end

      def bound_action
        @app_kernel
      end

      def application_kernel
        @app_kernel
      end

      def action_adapter
        nil
      end

      def invocation
        self
      end

      def write_invocation_string_parts y
        y.concat @resources.invocation_s_a ; nil
      end

      def app_name
        Callback_::Name.via_module( @mod ).as_slug  # etc.
      end

      def get_styled_description_string_array_via_name nm  # for #ouroboros
        [ "the #{ nm.as_slug } utility" ]  # placeholder
      end

      def has_description
      end

      def receive_invitation ev, adapter
        ( @invite_ev_a ||= [] ).push [ ev, adapter ] ; nil
      end

      attr_reader :invite_ev_a

      def maybe_use_exit_status d  # #note-075
        if ! instance_variable_defined? :@exit_status or @exit_status < d
          @exit_status = d ; nil
        end
      end

      def unbound_action_via_normalized_name i_a
        @app_kernel.unbound_action_via_normalized_name i_a
      end

      def payload_output_line_yielder
        @poly ||= ::Enumerator::Yielder.new( & @resources.sout.method( :puts ) )
      end

      def leaf_class
        self.class::Action_Adapter
      end

      def branch_class
        self.class::Branch_Adapter
      end

      def expression_agent_class
        self.class.const_get :Expression_Agent, false
      end

    private

      def flush_any_invitations
        invite_ev_a and flush_invitations
      end

      def flush_invitations
        seen_i_a_h = {} ; seen_general_h = {}
        invite_ev_a.each do |ev, adapter|
          ev_ = ev.to_event
          if ev_.has_tag :invite_to_action
            i_a = ev_.invite_to_action
            seen_i_a_h.fetch i_a do
              adapter.help_renderer.output_invite_to_particular_action i_a
              seen_i_a_h[ i_a ] = true
            end
          else
            k_x = adapter.bound_action.class.name.intern  # must work for proc proxies too
            seen_general_h.fetch k_x do
              seen_general_h[ k_x ] = true
              adapter.output_invite_to_general_help
            end
          end
        end.clear
      end

      def whn_result_is_trueish x

        if ACHIEVED_ == x  # covered
          SUCCESS_
        elsif x.respond_to? :bit_length  # covered
          x
        elsif x.respond_to? :id2name  # covered by [cu]
          x
        elsif x.respond_to? :ascii_only?  # visually by [tm] paths
          @resources.sout.puts x
          SUCCESS_
        else
          CLI_::When_Result_::Looks_like_stream.new( @adapter, x ).execute
        end
      end
    end

    # ~

    class Branch_Invocation__ < Invocation__

      Actions = ::Module.new.freeze  # #note-165

      def members
        [ * super ]
      end

      def resources
        @resources
      end

    private

      def resolve_properties
        @front_properties = Properties__.new
      end

      def _to_full_inferred_property_stream
        st = @front_properties.to_stream
        st.push_by STANDARD_ACTION_PROPERTY_BOX__.fetch :ellipsis
      end

    public

      def receive_no_matching_via_token__ token

        _bc = _bound_call_for_unrecognized_via token
        call_bound_call _bc
      end

      def receive_multiple_matching_via_adapters_and_token__ a, token

        _bc = _bound_call_for_ambiguous_via a, token
        call_bound_call _bc
      end

    private

      def call_bound_call exe
        exe.receiver.send exe.method_name, * exe.args
      end

      def _some_bound_call

        if argv.length.zero?

          _bound_call_when_no_arguments

        elsif DASH_BYTE_ == argv.first.getbyte( 0 )

          __bound_call_via_option_looking_first_arg
        else
          _bound_call_via_action_looking_first_argument
        end
      end

      def _bound_call_when_no_arguments
        CLI_::When_::No_Arguments.new action_prop, help_renderer
      end

      def action_prop
        @front_properties.fetch :action
      end

      def _bound_call_via_action_looking_first_argument

        token = @resources.argv.shift
        @adapter_a = find_matching_action_adapters_against_tok_ token

        case 1 <=> @adapter_a.length

        when  0
          @adapter = @adapter_a.fetch 0
          @adapter_a = nil
          __bound_call_via_adapter

        when  1
          _bound_call_for_unrecognized_via token

        when -1
          _bound_call_for_ambiguous_via @adapter_a, token

        end
      end

    public

      def retrieve_bound_action_via_nrml_nm i_a
        retrv_bound_action_via_normal_name_symbol_stream(
          Callback_::Polymorphic_Stream.via_array i_a )
      end

      def retrv_bound_action_via_normal_name_symbol_stream sym_st

        ad_st = to_adapter_stream
        sym = sym_st.gets_one

        ad = ad_st.gets
        while ad
          if sym == ad.name.as_lowercase_with_underscores_symbol
            found = ad
            break
          end
          ad = ad_st.gets
        end

        if found
          found.receive_frame self
          if sym_st.unparsed_exists
            found.retrv_bound_action_via_normal_name_symbol_stream sym_st
          else
            found
          end
        else
          raise ::KeyError, "not found: '#{ sym }'"
        end
      end

      def find_matching_action_adapters_against_tok_ tok

        _unbound_a = __array_of_matching_unbounds_against_token tok

        _unbound_a.map do | unbound |

          _adapter_via_unbound unbound

        end
      end

      def to_adapter_stream

        # rely on your associated bound action to give you an unbound action
        # stream representing its children. your bound action may be for e.g
        # a model instance just querying its child consts, or maybe it is an
        # arbitrary kernel doing something else, you neither know nor care.

        bound_action.to_unbound_action_stream.map_by do | unbound |

          _adapter_via_unbound unbound

        end
      end

      def __array_of_matching_unbounds_against_token tok
        Brazen_.lib_.basic::Fuzzy.reduce_to_array_stream_against_string(
          bound_action.to_unbound_action_stream,
          tok,
          -> unbound do
            unbound.name_function.as_slug
          end )
      end

      def _adapter_via_unbound unbound
        if unbound.is_branch
          __branch_class_for_unbound_action( unbound ).new unbound, bound_action
        else
          __leaf_class_for_unbound_action( unbound ).new unbound, bound_action
        end
      end

      # this is CLI. you need not cache these.

      def __branch_class_for_unbound_action unbound

        _any_specialized_adapter_in_self_for( unbound ) || branch_class
      end

      def __leaf_class_for_unbound_action unbound

        __any_specialized_adapter_under_model_node_for( unbound ) ||

          _any_specialized_adapter_in_self_for( unbound ) || leaf_class
      end

      # ~ begin modalities (per model)

      def __any_specialized_adapter_under_model_node_for unbound  # leaf

        mc = unbound.model_class
        if mc.respond_to?( :entry_tree ) && mc.entry_tree.has_entry( MODA___ )

          # hacking a peek into the filesystem (for free) here is not as ugly
          # as a) needing to opt-in to boxxy everywhere or b) requiring stubs

          mc.const_get :Modalities, false
        end
        if mc.const_defined? :Modalities
          __any_branch_or_leaf_class_for_unoubnd_when_modalities unbound
        end
      end

      def __any_branch_or_leaf_class_for_unoubnd_when_modalities unb

        sym = unb.name_function.as_const
        _box = unb.model_class::Modalities::CLI::Actions
        if _box.const_defined? sym, false
          _box.const_get sym
        end
      end

      MODA___ = 'modalities'

      # ~ end

      def _any_specialized_adapter_in_self_for unbound  # branch or leaf

        # the "classical" way to override - all special actions in one file

        sym = unbound.name_function.as_const
        if self.class::Actions.const_defined? sym, false
          self.class::Actions.const_get sym
        end
      end

      def leaf_class
        @parent.leaf_class
      end

      def branch_class
        @parent.branch_class
      end

      def wrap_adapter_stream_with_ordering_buffer_ st
        Callback_::Stream.ordered st
      end

    private

      def _bound_call_for_unrecognized_via token

        CLI_::When_::No_Matching_Action.new token, help_renderer, self
      end

      def __bound_call_via_option_looking_first_arg

        prepare_to_parse_parameters
        bc = bound_call_from_parse_options
        bc or _bound_call_via_parsed_options
      end

      def _bound_call_via_parsed_options
        if @mutable_backbound_iambic.length.zero?
          if argv.length.zero?
            _bound_call_when_no_arguments
          else
            _bound_call_via_action_looking_first_argument
          end
        else
          __bound_call_via_successfully_parsed_options
        end
      end

      def __bound_call_via_successfully_parsed_options
        a = [] ; scn = to_actual_parameters_stream
        scn.next
        begin
          i, x = scn.pair
          cls = bound_call_class_via_option_property_name_i i
          a.push cls.new( x, help_renderer, self )
        end while scn.next
        Aggregate_Bound_Call__.new a
      end

      def to_actual_parameters_stream
        Actual_Parameter_Scanner__.new @mutable_backbound_iambic, @front_properties
      end

      def _bound_call_for_ambiguous_via adapter_a, token

        CLI_::When_::Multiple_Matching_Actions.
          new adapter_a, token, help_renderer
      end

      def __bound_call_via_adapter

        @adapter.__bound_call_via_receive_frame self
      end
    end

    # ~

    Adapter_Methods__ = ::Module.new

    Action_Adapter = class Action_Adapter_ < Invocation__

      include Adapter_Methods__

      def initialize unbound, boundish
        super
        @bound.accept_parent_node_ boundish
      end

      def members
        [ * super ]
      end

      def _to_full_inferred_property_stream
        if @front_properties
          @front_properties.to_stream
        else
          Callback_::Stream.via_nonsparse_array EMPTY_A_
        end.push_by STANDARD_ACTION_PROPERTY_BOX__.fetch :help
      end

      def receive_show_help_ otr
        receive_frame otr
        help_renderer.output_help_screen
        SUCCESS_
      end

      def _some_bound_call

        prepare_to_parse_parameters
        bc = bound_call_from_parse_options
        bc or _bound_call_via_parsed_options
      end

      def _bound_call_via_parsed_options
        if @seen_h[ :help ]
          bound_call_for_help_request
        else
          __bound_call_via_ARGV
        end
      end

      def bound_call_for_help_request  # :+#public-API
        a = []
        a.push bound_call_class_via_option_property_name_i( :help ).
           new( nil, help_renderer, self )
        if argv.length.nonzero?
          a.push CLI_::When_::Unhandled_Arguments.
            new argv, help_renderer
        end
        Aggregate_Bound_Call__.new a
      end

      def __bound_call_class_for__help__option
        When_Action_Help__
      end

      def __bound_call_via_ARGV

        _n11n = Action_Adapter_::Arguments.normalization(
          @categorized_properties.arg_a || EMPTY_A_ )

        @arg_parse = _n11n.new_via_argv argv

        ev = @arg_parse.execute
        if ev
          __bound_call_when_ARGV_parsing_error_event ev
        else
          __bound_call_via_parsed_ARGV
        end
      end

      def __bound_call_when_ARGV_parsing_error_event ev
        send :"__bound_call_when__#{ ev.terminal_channel_i }__arguments", ev
      end

      def __bound_call_when__missing__arguments ev
        CLI_::When_::Missing_Arguments.new ev, help_renderer
      end

      def __bound_call_when__extra__arguments ev
        CLI_::When_::Extra_Arguments.new ev, help_renderer
      end

      def __bound_call_via_parsed_ARGV

        @mutable_backbound_iambic.concat @arg_parse.release_result_iambic

        if @categorized_properties.env_a
          bc = __process_environment
        end

        bc or begin
          __bound_call_via_mutable_backbound_iambic
        end
      end

      def __process_environment

        env = @resources.env

        @categorized_properties.env_a.each do | prp |
          s = env[ environment_variable_name_string_via_property prp ]
          s or next
          cased_i = prp.name_symbol.downcase  # [#039] casing
          @seen_h[ cased_i ] and next
          @mutable_backbound_iambic.push cased_i, s
        end
        NIL_
      end

      def environment_variable_name_string_via_property prp
        "#{ __APPNAME }_#{ prp.name.as_lowercase_with_underscores_symbol.id2name.upcase }"
      end

      def __APPNAME
        @__APPNAME ||= application_kernel.app_name.gsub( /[^[:alnum:]]+/, EMPTY_S_ ).upcase
      end

      def __bound_call_via_mutable_backbound_iambic

        ok = via_bound_action_mutate_mutable_backbound_iambic @mutable_backbound_iambic

        if ok
          __bound_call_via_bound_action_and_mutated_backbound_iambic
        else
          Callback_::Bound_Call.via_value ok  # failure is not an option
        end
      end

      def via_bound_action_mutate_mutable_backbound_iambic x_a  # :+#public-API :+#hook-in

        # ~ begin experiment: one way to give stdout to the action

        prp = @bound.any_formal_property_via_symbol :downstream
        if prp && prp.is_hidden
          x_a.push :downstream, @resources.sout
        end

        # ~ end

        ACHIEVED_
      end

      def __bound_call_via_bound_action_and_mutated_backbound_iambic

        bc = @bound.bound_call_against_polymorphic_stream(

          Callback_::Polymorphic_Stream.via_array @mutable_backbound_iambic )

        bc and bound_call_via_bound_call_from_back bc
      end

      def bound_call_via_bound_call_from_back bc  # :+#public-API :+#hook-in

        # experiment for [#060] the ability to customize rendering (beyond expag)

        bc
      end

      Autoloader_[ self ]

      self
    end

    class As_Bound_Call_

      def receiver
        self
      end

      def method_name
        :produce_result
      end

      def args
      end

      def block
      end
    end

    class When_Action_Help__ < As_Bound_Call_

      def initialize _, help_renderer, _action_adapter
        @help_renderer = help_renderer
        _ and self._SANITY
      end

      def produce_result
        @help_renderer.output_help_screen
        SUCCESS_
      end
    end

    class Branch_Adapter < Branch_Invocation__

      include Adapter_Methods__

      def receive_show_help_ otr
        receive_frame otr
        CLI_::When_::Help.new( nil, help_renderer, self ).produce_result
      end
    end

    module Adapter_Methods__

      def initialize unbound, boundish  # :+#public-API
        @bound = unbound.new boundish, & handle_event_selectively
      end

      def members
        [ :bound_, :resources, * super ]
      end

      def bound_  # #experiment
        @bound
      end

      attr_reader :resources  # for magic results [#021]

      def name
        @bound.name
      end

      def is_visible
        @bound.is_visible
      end

      def has_description
        @bound.has_description
      end

      def under_expression_agent_get_N_desc_lines exp, d=nil
        @bound.under_expression_agent_get_N_desc_lines exp, d
      end

      def __bound_call_via_receive_frame otr
        receive_frame otr
        _some_bound_call
      end

      def receive_frame otr
        @parent = otr
        @resources = otr.resources
        resolve_properties
        resolve_categorized_properties
        NIL_
      end

      def bound_action
        @bound
      end

      def action_adapter
        self
      end

      def invocation
        self
      end

      def retrieve_bound_action_via_nrml_nm i_a
        @parent.retrieve_bound_action_via_nrml_nm i_a
      end

      def retrieve_unbound_action * i_a
        @parent.unbound_action_via_normalized_name i_a
      end

      def unbound_action_via_normalized_name i_a
        @parent.unbound_action_via_normalized_name i_a
      end

      def application_kernel
        @parent.application_kernel
      end

      def handle_event_selectively  # :+#public-API #hook-in

        # as it must it produces a [#cb-017] selective listener-style proc.
        # this default implementation accepts and routes every event to our
        # friendly general-purpose behavior dispatcher, but some hookers-in
        # will for example first check if a special method is defined which
        # corresponds to the channel name in some way and instead use that.

        -> * i_a, & x_p do
          receive_uncategorized_emission i_a, & x_p
        end
      end

      def receive_uncategorized_emission i_a, & x_p

        if i_a && :expression == i_a[ 1 ]
          send :"receive__#{ i_a[ 0 ] }__expression", * i_a[ 2 .. -1 ], & x_p
        else
          receive_event_on_channel x_p[], i_a
        end
      end

      # ~ begin implement :+[#023]:

      def receive__error__expression sym, & msg_p

        receive_negative_event _event_via_expression( false, sym, & msg_p )
      end

      def receive__info__expression sym, & msg_p

        receive_neutral_event _event_via_expression( nil, sym, & msg_p )
      end

      def receive__payload__expression sym, & msg_p

        receive_payload_event _event_via_expression( true, sym, & msg_p )
      end

      def _event_via_expression ok, sym, & msg_p

        Callback_::Event.inline_with sym, :ok, ok do | y, _ |
          instance_exec y, & msg_p
        end
      end

      # ~ end

      def receive_event_on_channel ev, i_a  # :+#public-API
        ev_ = ev.to_event
        has_OK_tag = if ev_.has_tag :ok
          ok_x = ev_.ok
          true
        end
        if has_OK_tag && ! ok_x.nil?
          if ok_x
            if ev_.has_tag :is_completion and ev_.is_completion
              receive_completion_event ev
            elsif :payload == i_a.first  # or ! ev.verb_lexeme
              receive_payload_event ev
            else
              receive_positive_event ev
            end
          else
            receive_negative_event ev
          end
        else
          receive_neutral_event ev
        end
      end

      def receive_positive_event ev
        ev_ = ev.to_event
        a = render_event_lines ev
        s = inflect_line_for_positivity_via_event a.first, ev
        s and a[ 0 ] = s
        send_non_payload_event_lines_with_redundancy_filter a
        maybe_use_exit_status_via_OK_or_not_OK_event ev_ ; nil
      end

      def receive_negative_event ev
        a = render_event_lines ev
        s = maybe_inflect_line_for_negativity_via_event a.first, ev
        s and a[ 0 ] = s
        send_non_payload_event_lines_with_redundancy_filter a
        send_invitation ev
        maybe_use_exit_status some_err_code_for_event ev ; nil
      end

      def receive_success_event ev
        receive_completion_event ev  # while it works
      end

      def receive_completion_event ev
        a = render_event_lines ev
        s = maybe_inflect_line_for_completion_via_event a.first, ev
        s and a[ 0 ] = s
        send_non_payload_event_lines a
        maybe_use_exit_status SUCCESS_ ; nil
      end

      def receive_neutral_event ev
        a = render_event_lines ev
        send_non_payload_event_lines a
        maybe_use_exit_status SUCCESS_ ; nil
      end

      attr_reader :invite_ev_a

      def receive_invitation ev, adapter
        @parent.receive_invitation ev, adapter ; nil
      end

      def output_invite_to_general_help
        help_renderer.output_invite_to_general_help
      end

      def receive_payload_event ev
        send_payload_event_lines render_event_lines ev
        maybe_use_exit_status_via_OK_or_not_OK_event ev.to_event
      end

      def receive_info_event ev
        _a = render_event_lines ev
        send_non_payload_event_lines _a ; nil
      end

      def expression_agent_class
        @parent.expression_agent_class
      end

      def payload_output_line_yielder
        @parent.payload_output_line_yielder
      end

    private

      def send_invitation ev
        @parent.receive_invitation ev, self
      end

      def maybe_inflect_line_for_positivity_via_event s, ev
        if ev.verb_lexeme
          inflect_line_for_positivity_via_event s, ev
        else
          s
        end
      end

      def inflect_line_for_positivity_via_event s, ev
        if ev.respond_to? :inflected_noun
          __ilfp s, ev
        else
          s
        end
      end

      def __ilfp s, ev
        open, inside, close = unparenthesize s
        downcase_first inside
        n_s = ev.inflected_noun
        v_s = ev.verb_lexeme.progressive
        gerund_phrase = "#{ [ v_s, n_s ].compact * SPACE_ }"
        inside_ = if HACK_IS_ONE_WORD_RX__ =~ inside
          "#{ inside } #{ gerund_phrase }"
        else
          "while #{ gerund_phrase }, #{ inside }"
        end
        "#{ open }#{ inside_ }#{ close }"
      end

      def maybe_inflect_line_for_negativity_via_event s, ev
        open, inside, close = unparenthesize s
        downcase_first inside
        if ev.respond_to? :inflected_verb
          v_s = ev.inflected_verb
          lex = ev.noun_lexeme and n_s = lex.lemma
          prefix = "couldn't #{ [ v_s, n_s ].compact * SPACE_ } because "
        end
        "#{ open }#{ prefix }#{ inside }#{ close }"
      end

      def maybe_inflect_line_for_completion_via_event s, ev
        if ev.respond_to? :inflected_noun
          __milfc s, ev
        else
          s
        end
      end

      def __milfc s, ev
        open, inside, close = unparenthesize s
        downcase_first inside
        if HACK_IS_ONE_WORD_RX__ =~ inside
          maybe_inflect_line_for_positivity_via_event s, ev
        else
          n_s = ev.inflected_noun
          v_s = ev.verb_lexeme.preterite
          prefix = if n_s
            "#{ v_s } #{ n_s }: "
          else
            v_s
          end
          "#{ open }#{ prefix }#{ inside }#{ close }"
        end
      end
      HACK_IS_ONE_WORD_RX__ = /\A[a-z]+\z/

      def unparenthesize s
        LIB_.basic::String.unparenthesize_message_string s
      end

      def downcase_first s
        s and UCASE__.include? s.getbyte( 0 ) and s[ 0 ] = s[ 0 ].downcase
      end
      UCASE__ = 'A'.getbyte( 0 ) .. 'Z'.getbyte( 0 )

      def render_event_lines ev
        ev.express_into_under y=[], expression_agent
        y
      end

      def send_non_payload_event_lines_with_redundancy_filter a
        if 1 == a.length
          s = redundancy_filter[ a.first ]
          send_non_payload_event_lines [ s ]
        else
          send_non_payload_event_lines a
        end
      end

      def redundancy_filter
        @redundancy_filter ||= CLI_::Redundancy_Filter__.new
      end

      def send_payload_event_lines a
        a.each( & payload_output_line_yielder.method( :<< ) ) ; nil
      end

      def send_non_payload_event_lines a
        a.each( & help_renderer.y.method( :<< ) ) ; nil
      end

      def maybe_use_exit_status_via_OK_or_not_OK_event ev
        d = any_err_code_for_event ev
        d or ev.ok && ( d = SUCCESS_ )
        d ||= some_err_code_for_event ev
        maybe_use_exit_status d ; nil
      end

      def any_err_code_for_event ev
        any_ext_status_for_chan_i ev.terminal_channel_i
      end

      def any_ext_status_for_chan_i i
        Brazen_::API.exit_statii[ i ]
      end

      def some_err_code_for_event ev
        any_err_code_for_event( ev ) || GENERIC_ERROR_
      end

    public

      def app_name
        @parent.app_name
      end

      def maybe_use_exit_status d
        @parent.maybe_use_exit_status d
      end

      # ~ #hook-outs for adjunct facet: ordering

      def name_value_for_order
        @bound.name.as_lowercase_with_underscores_symbol
      end

      def after_name_value_for_order
        @bound.class.after_name_symbol
      end
    end

    # ~

    class Invocation__

      def members
        EMPTY_A_
      end

      def begin_option_parser  # :+#public-API
        option_parser_class.new
      end

      def option_parser_class
        Option_parser__[]
      end

      def __receive_categorized_properties cp
        @categorized_properties = cp
        NIL_
      end

      def invocation_string
        write_invocation_string_parts y = []
        y * SPACE_
      end

      def write_invocation_string_parts y
        @parent.write_invocation_string_parts y
        y << name.as_slug ; nil
      end

      def __populate_option_parser_with_generated_opts op, opt_a

        h = Build_unique_letter_hash__[ opt_a ]

        opt_a.each do |prp|

          args = []
          letter = h[ prp.name_symbol ]
          letter and args.push "-#{ letter }"
          base = "--#{ prp.name.as_slug }"

          if prp.takes_argument
            if prp.argument_is_required
              args.push "#{ base } #{ argument_label_for prp }"
            else
              args.push "#{ base } [#{ argument_label_for prp }]"
            end
          else
            args.push base
          end

          _p = optparse_behavior_for_property prp
          prp.has_description and __render_property_description args, prp
          op.on( * args, & _p )
        end
        NIL_
      end

      # ~ begin

      def optparse_behavior_for_property prp  # :+#public-API #hook-in

        -> x do
          m = :"receive__#{ prp.name_symbol }__option"
          if respond_to? m
            send m, x, prp
          else
            __receive_uncategorized_option x, prp
          end
          NIL_
        end
      end

      def __receive_uncategorized_option x, prp

        if prp.takes_argument

          if prp.takes_many_arguments

            __receive_list_option x, prp
          else
            __receive_common_argumented_option x, prp
          end
        elsif :zero_or_more == prp.parameter_arity

          __receive_incrementing_option prp
        else

          __receive_flag_option prp
        end
        NIL_
      end

      def __receive_list_option x, prp

        @seen_h[ prp.name_symbol ] = true
        @mutable_backbound_iambic.push prp.name_symbol, [ x ]  # hm..
        NIL_
      end

      def __receive_common_argumented_option x, prp

        @seen_h[ prp.name_symbol ] = true
        @mutable_backbound_iambic.push prp.name_symbol, x
        NIL_
      end

      def __receive_incrementing_option prp

        k = prp.name_symbol
        increment_seen_count k
        @mutable_backbound_iambic.push k
        NIL_
      end

      def increment_seen_count k

        yes = true
        @seen_h.fetch k do
          yes = false
          @seen_h[ k ] = 1
        end
        if yes
          @seen_h[ k ] += 1
        end
        NIL_
      end

      def __receive_flag_option prp

        @seen_h[ prp.name_symbol ] = true
        @mutable_backbound_iambic.push prp.name_symbol
        NIL_
      end

      # ~ end

      def __render_property_description a, prop
        expag = expression_agent
        expag.current_property = prop
        a.concat prop.under_expression_agent_get_N_desc_lines expag ; nil
      end

      def write_full_syntax_strings__ y
        write_any_primary_syntax_string y
        write_any_auxiliary_syntax_string y
      end

      def write_any_primary_syntax_string y
        s = primary_syntax_string
        s and y << s ; nil
      end

      def primary_syntax_string
        help_renderer.produce_full_main_syntax_string
      end

      def write_any_auxiliary_syntax_string y
        help = _to_full_inferred_property_stream.each.detect do |prop|
          :help == prop.name_symbol
        end
        if help
          ai_s = invocation_string
          op_s = help_renderer.as_opt_render_property help
          y << "#{ ai_s } #{ op_s }" ; nil
        end
      end

      def argument_label_for prop
        s = prop.argument_moniker
        s or prop.name.as_variegated_string.split( UNDERSCORE_ ).last.upcase
      end

      def prepare_to_parse_parameters  # :+#public-API :+#hook-in
        @mutable_backbound_iambic = []  # :+#public-API (name)
        @seen_h = {}
        NIL_
      end

      def bound_call_from_parse_options  # :+#public-API
        @op ||= option_parser
        @op.parse! argv
        NIL_
      rescue ::OptionParser::ParseError => e
        __bound_call_when_parse_error e
      end

      def option_parser
        help_renderer.op
      end

      def bound_call_class_via_option_property_name_i i
        m_i = :"__bound_call_class_for__#{ i }__option"
        if respond_to? m_i
          send m_i
        else
          i_ = Callback_::Name.via_variegated_symbol( i ).as_const
          CLI_::When_.const_get( i_, false )
        end
      end

      def __bound_call_when_parse_error e
        CLI_::When_::Parse_Error.new e, help_renderer
      end

      def expression_agent
        @categorized_properties.expression_agent
      end

      def categorized_properties
        @categorized_properties
      end

      def properties
        @front_properties
      end

      def stderr
        @resources.serr
      end

      def help_renderer
        @categorized_properties.help_renderer
      end

    private

      def argv
        @resources.argv
      end

      def resolve_categorized_properties
        @categorized_properties = Categorize_properties___[
          _to_full_inferred_property_stream, self ]
        NIL_
      end
    end

    Option_parser__ = Callback_.memoize do
      require 'optparse'
      ::OptionParser
    end

    # ~

    class Categorize_properties___  # #note-600

      Actor_.call self, :properties, :scn, :adapter

      def execute
        Categorized_Properties___.new do | cp |
          @adapter.__receive_categorized_properties cp
          @categorized_properties = cp
          __work
        end
        @categorized_properties
      end

      def __work

        @arg_a = @env_a = @opt_a = @many_a = nil

        d = 0 ; @original_index = {}

        begin
          prp = @scn.gets
          prp or break

          @original_index[ prp.name_symbol ] = ( d += 1 )

          if prp.can_be_from_environment  # probably goes away
            ( @env_a ||= [] ).push prp
            redo
          end

          if prp.is_hidden
            redo
          end

          if prp.takes_many_arguments
            ( @many_a ||= [] ).push prp
            redo
          end

          _is_effectively_required = if prp.is_required
            if prp.has_default
              false  # explained fully at [#006]
            else
              true
            end
          end

          if _is_effectively_required

            ( @arg_a ||= [] ).push prp
          else

            ( @opt_a ||= [] ).push prp
          end

          redo
        end while nil

        if @many_a
          __determine_placement_for_many
        end

        __maybe_make_experimental_aesthetic_readjustment

        o = @categorized_properties
        o.adapter = @adapter
        o.arg_a = @arg_a.freeze
        o.env_a = @env_a.freeze
        o.opt_a = @opt_a.freeze
        NIL_
      end

      def __maybe_make_experimental_aesthetic_readjustment  # #note-575

        if ! @many_a && @opt_a && ( ! @arg_a || @opt_a.last.takes_argument  ) # (a), (b) and (c)
          __make_experimental_aestethic_adjustment
        end
      end

      def __make_experimental_aestethic_adjustment  # #note-610

        d = @opt_a.length
        while d.nonzero?
          prop = @opt_a.fetch d -= 1
          prop.takes_argument or next
          STANDARD_BRANCH_PROPERTY_BOX__.has_name( prop.name_symbol ) and next
          found = prop
          break
        end
        if found
          ( @arg_a ||= [] ).push found
          @opt_a[ d, 1 ] = EMPTY_A_
          @opt_a.length.zero? and @opt_a = nil
        end ; nil
      end

      def __determine_placement_for_many

        if @arg_a
          @arg_a.push @many_a.pop
          _re_order @arg_a
        else
          @arg_a = [ @many_a.pop ]
        end
        if @many_a.length.nonzero?
          @opt_a.concat @many_a
          _re_order @opt_a
        end
        @many_a = true
      end

      def _re_order a
        a.sort_by! do |prop|
          @original_index.fetch prop.name_symbol
        end ; nil
      end
    end

    class Categorized_Properties___

      def initialize

        @expression_agent = @help_renderer = @op = nil
        yield self
        @expression_agent || __resolve_expression_agent
        @op || __resolve_option_parser
        @help_renderer || __resolve_help_renderer
      end

      attr_accessor :opt_a, :arg_a, :env_a
      attr_accessor :adapter
      attr_reader :expression_agent, :help_renderer, :categorized_properties

      def __resolve_expression_agent
        @expression_agent = @adapter.expression_agent_class.new self ; nil
      end

      def __resolve_option_parser

        op = @adapter.begin_option_parser
        if op
          if @opt_a
            @adapter.__populate_option_parser_with_generated_opts op, @opt_a
          end
          @op = op
        else
          @op = nil
        end
        NIL_
      end

      def __resolve_help_renderer
        CLI_::Action_Adapter_::Help_Renderer.new @op, @adapter; nil
      end

      def receive_help_renderer o
        @help_renderer = o
        @opt_a and __add_option_section o
        @arg_a and __add_arg_section o
        @env_a and __add_env_section o
      end

      def __add_option_section o
        o.add_section :ad_hoc_section, 'options' do |help|
          help.output_option_parser_summary
        end
      end

      def __add_arg_section o
        o.arg_a = @arg_a
        o.add_section :item_section, 'argument', @arg_a ; nil
      end

      def __add_env_section o
        o.add_section :item_section, 'environment variable', @env_a do | prp |
          adapter.environment_variable_name_string_via_property prp
        end
      end

      def rendering_method_name_for_property prp  # for expag

        __any_rendering_method_name_for_property( prp ) ||
          :render_property_as_unknown
      end

      def __any_rendering_method_name_for_property prp

        sym, = category_symbol_and_property_via_name_symbol prp.name_symbol

        if sym
          rendering_method_name_for_property_category_name_symbol sym
        end
      end

      def rendering_method_name_for_property_category_name_symbol sym
        :"render_property_as__#{ sym }__"
      end

      def category_symbol_and_property_via_name_symbol sym

        prp = __option_via_name_symbol sym

        if prp
          [ :option, prp ]
        else

          prp = __argument_via_name_symbol sym
          if prp
            [ :argument, prp ]

          else

            prp = __environment_variable_via_name_symbol sym
            if prp
              [ :environment_variable, prp ]
            end
          end
        end
      end

      def __option_via_name_symbol sym
        any_i_in_a sym, @opt_a
      end

      def __argument_via_name_symbol sym
        any_i_in_a sym, @arg_a
      end

      def __environment_variable_via_name_symbol sym
        any_i_in_a sym, @env_a
      end

      def any_i_in_a i, a
        if a
          a.detect do |o|
            i == o.name_symbol
          end
        end
      end
    end

    Build_unique_letter_hash__ = -> opt_a do
      h = { } ; num_times_seen_h = ::Hash.new { |h_, k| h_[ k ] = 0 }
      opt_a.each do |prop|
        name_s = prop.name.as_variegated_string
        d = name_s.getbyte 0
        case num_times_seen_h[ d ] += 1
        when 1
          h[ prop.name_symbol ] = name_s[ 0, 1 ]
        when 2
          h.delete prop.name_symbol
        end
      end
      h
    end

    class Properties__
      def initialize
        @box = STANDARD_BRANCH_PROPERTY_BOX__
      end
      def fetch i
        @box.fetch i
      end
      def to_stream
        scn = @box.to_value_stream
        Callback_.stream do
          scn.gets
        end
      end
    end

    class Property__
      def initialize name_i, * x_a
        @argument_arity = :one
        @custom_moniker = nil
        @desc = nil
        @name = Callback_::Name.via_variegated_symbol name_i
        x_a.each_slice( 2 ) do |i, x|
          instance_variable_set :"@#{ i }", x
        end
        freeze
      end
      attr_reader :desc, :name,
        :argument_arity,
        :argument_moniker,
        :can_be_from_environment,
        :custom_moniker,
        :is_required,
        :parameter_arity

      def is_hidden
        false
      end

      def name_symbol
        @name.as_variegated_symbol
      end

      def has_custom_moniker
        @custom_moniker
      end

      def has_description
        @desc
      end

      def under_expression_agent_get_N_desc_lines expag, d=nil
        LIB_.N_lines.new( [], d, [ @desc ], expag ).execute
      end

      def takes_argument  # zero to many takes argument
        :zero != @argument_arity
      end

      def argument_is_required
        :one == @argument_arity or :one_or_more == @argument_arity
      end

      def takes_many_arguments
        :zero_or_more == @argument_arity or :one_or_more == @argument_arity
      end

      def has_default
      end
    end

    STANDARD_ACTION_PROPERTY_BOX__ = -> do
      box = Box_.new
      box.add :help, Property__.new( :help,
        :argument_arity, :zero,
        :desc, -> y do
          y << "this screen"
        end )
      box.add :ellipsis, Property__.new( :ellipsis,
        # :argument_arity, :zero_or_more,
        :argument_arity, :zero_or_one,
        :custom_moniker, '..' )

      box.freeze
    end.call

    STANDARD_BRANCH_PROPERTY_BOX__ = -> do
      box = Box_.new
      box.add :action, Property__.new( :action, :is_required, true )
      box.add :help, Property__.new( :help,
        :argument_arity, :zero_or_one,
        :argument_moniker, 'cmd',
        :desc, -> y do
          y << 'this screen (or help for action)'
      end )
      box.freeze
    end.call

    class Actual_Parameter_Scanner__

      def initialize mutable_backbound_iambic, props

        scn = Callback_::Polymorphic_Stream.via_array mutable_backbound_iambic
        prop = i = x = nil
        @prop_p = -> { prop }
        @pair_p = -> { [ i, x ] }
        @next_p = -> do
          if scn.unparsed_exists
            i = scn.gets_one
            prop = props.fetch i
            x = ( scn.gets_one if prop.takes_argument )
            true
          else
            prop = i = x = nil
          end
        end
      end
      def next ; @next_p[] end
      def pair ; @pair_p[] end
      def prop ; @prop_p[] end
    end

    class Resources__

      def initialize a, mod
        @mod = mod
        @sin, @sout, @serr, @s_a = a
        if @s_a
          @s_a.last.nil? and @s_a[ -1 ] = Callback_::Name.via_module( @mod ).as_slug
        else
          @s_a = [ ::File.basename( $PROGRAM_NAME ) ].freeze
        end
      end

      def members
        [ :argv, :env, :invocation_s_a, :mod, :sin, :sout, :serr ]
      end

      attr_reader :argv, :env, :sin, :sout, :serr, :mod

      def invocation_s_a
        @s_a
      end

      def complete env, argv
        @argv = argv ; @env = env ; freeze ; nil
      end

      def new argv
        dup.__new argv
      end

      protected def __new  argv

        @argv = argv
        freeze
      end
    end

    class Aggregate_Bound_Call__ < As_Bound_Call_

      def initialize a
        @a = a
      end

      def produce_result
        scn = Callback_::Stream.via_nonsparse_array @a
        while exe = scn.gets
          value = exe.receiver.send exe.method_name, * exe.args
          value.nonzero? and break
        end
        value
      end
    end

    CLI_ = self
    DASH_BYTE_ = '-'.getbyte 0
    GENERIC_ERROR_ = 5
    NOTHING_ = nil
    SUCCESS_ = 0

    # we demonstrate how to mutate properties back-to-front with this bit of
    # ick (which crams these business-specifics into this node): at the time
    # the action is invoked, mutate the properties we get from the API to be
    # customized for this modality for these actions. it's CLI so there's no
    # point in memoizing anything: load-time and run-time are the same time.

    class Action_Adapter  # re-open

      MUTATE_THESE_PROPERTIES = %i(
        config_filename
        max_num_dirs
        workspace_path )

      def resolve_properties  # :+[#042] #nascent-operation

        @mutable_back_properties = nil
        @mutable_front_properties = nil

        @back_properties = @bound.formal_properties  # nil ok

        if @back_properties

          sym_a = self.class::MUTATE_THESE_PROPERTIES
          if sym_a

            bp = @back_properties
            sym_a.each do | sym |
              if bp.has_name sym
                send :"mutate__#{ sym }__properties"
              end
            end
          end
        end

        @front_properties ||= @back_properties

        nil
      end

      def mutate__config_filename__properties

        # exclude this formal property from the front. leave back as-is.

        mutable_front_properties.remove :config_filename
      end

      def mutate__max_num_dirs__properties  # ALSO handwritten below!

        # exclude this formal property from the front. in back, unbound it.

        mutable_front_properties.remove :max_num_dirs
        mutable_back_properties.replace_by :max_num_dirs do | prp |
          prp.without_default
        end
      end

      def mutate__workspace_path__properties

        # exclude this formal property from the front. default the back to CWD

        mutable_front_properties.remove :workspace_path
        mutable_back_properties.replace_by :workspace_path do | prp |
          prp.dup.set_default_proc do
            _present_working_directory
          end.freeze
        end
      end

      # ~ support

      def mutable_front_properties
        if ! @mutable_front_properties
          @mutable_front_properties = @back_properties.to_new_mutable_box_like_proxy
          @front_properties = @mutable_front_properties
        end
        @mutable_front_properties
      end

      def mutable_back_properties
        if ! @mutable_back_properties
          @mutable_back_properties = @back_properties.to_mutable_box_like_proxy
          @bound.change_formal_properties @mutable_back_properties  # might be same object
        end
        @mutable_back_properties
      end

      def _common_CLI_changes_for_path_property sym

        mutable_front_properties.replace_by sym do | prp |
          prp.dup.set_is_not_required.freeze
        end

        mutable_back_properties.replace_by sym do | prp |
          prp.dup.set_default_proc do
            _present_working_directory
          end.freeze
        end ; nil
      end

      def _present_working_directory
        ::Dir.pwd
      end
    end

    module Actions
      class Status < Action_Adapter
        def resolve_properties
          super
          _common_CLI_changes_for_path_property :path
          nil
        end

        def mutate__max_num_dirs__properties
          # override above - we do nothing. this tests env. vars. near [#017]
        end
      end

      class Workspace < Branch_Adapter
        Actions = ::Module
        class Actions::Summarize < Action_Adapter
          def resolve_properties
            super
            _common_CLI_changes_for_path_property :path
            nil
          end
        end
      end
    end
  end
end
