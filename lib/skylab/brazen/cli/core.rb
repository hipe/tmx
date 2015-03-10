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
    end

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

      attr_writer :env

      def invoke argv
        @resources.complete @env || ::ENV, argv
        resolve_properties
        resolve_partitions
        resolve_bound_call
        x = @bound_call.receiver.send @bound_call.method_name, * @bound_call.args
        flush_any_invitations
        if x
          whn_result_is_trueish x
        else
          @exit_status
        end
      end

    public

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

      def resolve_partitions
        @partitions = Build_partitions__[ to_full_inferred_prop_strm, self ]
      end

      def to_full_inferred_prop_strm
        st = @front_properties.to_stream
        st.push_by STANDARD_ACTION_PROPERTY_BOX__.fetch :ellipsis
      end

    public

      def receive_no_matching_action tok
        @token = tok
        resolve_bound_call_when_no_matching_action
        call_bound_call @bound_call
      end

    private

      def call_bound_call exe
        exe.receiver.send exe.method_name, * exe.args
      end

      def resolve_bound_call
        if argv.length.zero?
          resolve_bound_call_when_no_arguments
        elsif DASH_BYTE_ == argv.first.getbyte( 0 )
          resolve_bound_call_when_looks_like_option_for_first_argument
        else
          resolve_bound_call_when_looks_like_action_for_first_argument
        end
      end

      def resolve_bound_call_when_no_arguments
        @bound_call = CLI_::When_::No_Arguments.new action_prop, help_renderer
      end

      def action_prop
        @front_properties.fetch :action
      end

      def resolve_bound_call_when_looks_like_action_for_first_argument
        @token = @resources.argv.shift
        @adapter_a = find_matching_action_adapters_against_tok @token
        case 1 <=> @adapter_a.length
        when  0 ; resolve_bound_call_when_one_matching_adapter
        when  1 ; resolve_bound_call_when_no_matching_action
        when -1 ; resolve_bound_call_when_multiple_matching_adapters
        end     ; nil
      end

    public

      def retrieve_bound_action_via_nrml_nm i_a
        retrv_bound_action_via_normal_name_symbol_stream(
          Callback_::Iambic_Stream.via_array i_a )
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

      def find_matching_action_adapters_against_tok tok

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
        _any_branch_or_leaf_class_for_unbound( unbound ) || branch_class
      end

      def __leaf_class_for_unbound_action unbound
        _any_branch_or_leaf_class_for_unbound( unbound ) || leaf_class
      end

      def _any_branch_or_leaf_class_for_unbound unbound
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

      def resolve_bound_call_when_no_matching_action
        @bound_call = CLI_::When_::No_Matching_Action.new @token, help_renderer, self
      end

      def resolve_bound_call_when_looks_like_option_for_first_argument
        prepare_to_parse_parameters
        parse_options
        @bound_call or resolve_bound_call_when_parsed_options
      end

      def resolve_bound_call_when_parsed_options
        if @output_iambic.length.zero?
          if argv.length.zero?
            resolve_bound_call_when_no_arguments
          else
            resolve_bound_call_when_looks_like_action_for_first_argument
          end
        else
          resolve_bound_call_when_successfully_parsed_options
        end
      end

      def resolve_bound_call_when_successfully_parsed_options
        a = [] ; scn = to_actual_parameters_stream
        scn.next
        begin
          i, x = scn.pair
          cls = bound_call_class_via_option_property_name_i i
          a.push cls.new( x, help_renderer, self )
        end  while scn.next
        @bound_call = Aggregate_Bound_Call__.new a
      end

      def to_actual_parameters_stream
        Actual_Parameter_Scanner__.new @output_iambic, @front_properties
      end

      def resolve_bound_call_when_multiple_matching_adapters
        @bound_call = CLI_::When_::Ambiguous_Matching_Actions.new self._TODO
      end

      def resolve_bound_call_when_one_matching_adapter
        @adapter = @adapter_a.first
        @adapter_a = nil
        @adapter.receive_frame self
        @bound_call = @adapter.via_argv_resolve_some_bound_call
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

    private

      def resolve_partitions
        @partitions = Build_partitions__[ to_full_inferred_prop_strm, self ]
      end

      def to_full_inferred_prop_strm
        if @front_properties
          @front_properties.to_stream
        else
          Callback_::Stream.via_nonsparse_array EMPTY_A_
        end.push_by STANDARD_ACTION_PROPERTY_BOX__.fetch :help
      end

    public def receive_show_help otr
        receive_frame otr
        help_renderer.output_help_screen
        SUCCESS_
      end

      def resolve_bound_call
        prepare_to_parse_parameters
        parse_options
        @bound_call or resolve_bound_call_after_parsed_options
      end

      def resolve_bound_call_after_parsed_options
        if @seen_h[ :help ]
          resolve_bound_call_when_help_request
        else
          resolve_bound_call_when_any_args
        end
      end

      def resolve_bound_call_when_help_request
        a = []
        a.push bound_call_class_via_option_property_name_i( :help ).
           new( nil, help_renderer, self )
        if argv.length.nonzero?
          a.push CLI_::When_::Unhandled_Arguments.
            new argv, help_renderer
        end
        @bound_call = Aggregate_Bound_Call__.new a
      end

    public def bound_call_class_for_help_option
        When_Action_Help__
      end

      def resolve_bound_call_when_any_args
        _n11n = Action_Adapter_::Arguments.normalization(
          @partitions.arg_a || EMPTY_A_ )
        @arg_parse = _n11n.new_via_argv argv
        ev = @arg_parse.execute
        if ev
          resolve_bound_call_when_ARGV_parsing_error_event ev
        else
          resolve_bound_call_when_ARGV_parsed
        end
      end

      def resolve_bound_call_when_ARGV_parsing_error_event ev
        send :"resolve_bound_call_when_#{ ev.terminal_channel_i }_arguments", ev
      end

      def resolve_bound_call_when_missing_arguments ev
        @bound_call = CLI_::When_::Missing_Arguments.new ev, help_renderer
      end

      def resolve_bound_call_when_extra_arguments ev
        @bound_call = CLI_::When_::Extra_Arguments.new ev, help_renderer
      end

      def resolve_bound_call_when_ARGV_parsed
        @output_iambic.concat @arg_parse.release_result_iambic
        @partitions.env_a and process_environment
        @bound_call or via_output_iambic_resolve_bound_call
      end

      def process_environment

        env = @resources.env

        @partitions.env_a.each do | prp |
          s = env[ environment_variable_name_string_via_property prp ]
          s or next
          cased_i = prp.name_symbol.downcase  # [#039] casing
          @seen_h[ cased_i ] and next
          @output_iambic.push cased_i, s
        end
        nil
      end

      public def environment_variable_name_string_via_property prp
        "#{ __APPNAME }_#{ prp.name.as_lowercase_with_underscores_symbol.id2name.upcase }"
      end

      def __APPNAME
        @__APPNAME ||= application_kernel.app_name.gsub( /[^[:alnum:]]+/, EMPTY_S_ ).upcase
      end

      def via_output_iambic_resolve_bound_call

        # begin experiment
        prp = @bound.any_formal_property_via_symbol :downstream
        if prp && prp.is_hidden
          @output_iambic.push :downstream, @resources.sout
        end
        # end experiment

        @bound_call = @bound.bound_call_against_iambic_stream(
          Callback_::Iambic_Stream.via_array @output_iambic )

        @bound_call ||= Brazen_.bound_call.via_value @bound_call

        nil
      end

      Autoloader_[ self ]

      self
    end

    class Simple_Bound_Call_
      def receiver
        self
      end

      def method_name
        :produce_result
      end

      def args
      end
    end

    class When_Action_Help__ < Simple_Bound_Call_

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

      def receive_show_help otr
        receive_frame otr
        CLI_::When_::Help.new( nil, help_renderer, self ).produce_result
      end
    end

    module Adapter_Methods__

      def initialize unbound, boundish
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

      def receive_frame otr
        @parent = otr
        @resources = otr.resources
        resolve_properties
        resolve_partitions ; nil
      end

      def via_argv_resolve_some_bound_call
        resolve_bound_call
        @bound_call
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

        -> * i_a, & ev_p do
          receive_event_on_channel ev_p[], * i_a
        end
      end

      def receive_event_on_channel ev, * i_a  # :+#public-API
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
        ev.render_all_lines_into_under y=[], expression_agent
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

      def option_parser_class
        Option_parser__[]
      end

      def receive_partitions partitions
        @partitions = partitions ; nil
      end

      def invocation_string
        write_invocation_string_parts y = []
        y * SPACE_
      end

      def write_invocation_string_parts y
        @parent.write_invocation_string_parts y
        y << name.as_slug ; nil
      end

      def populate_option_parser_with_generated_opts op, opt_a
        h = Build_unique_letter_hash__[ opt_a ]
        opt_a.each do |prop|
          args = []
          letter = h[ prop.name_symbol ]
          letter and args.push "-#{ letter }"
          base = "--#{ prop.name.as_slug }"
          if prop.takes_argument
            if prop.argument_is_required
              args.push "#{ base } #{ argument_label_for prop }"
            else
              args.push "#{ base } [#{ argument_label_for prop }]"
            end
          else
            args.push base
          end
          _p = optparse_behavior_for_property prop
          prop.has_description and render_property_description args, prop
          op.on( * args, & _p )
        end ; nil
      end

      def optparse_behavior_for_property prop  # :+#public-API #hook-in
        if prop.takes_argument
          -> x do
            @seen_h[ prop.name_symbol ] = true
            @output_iambic.push prop.name_symbol, x
          end
        else
          -> _ do
            @seen_h[ prop.name_symbol ] = true
            @output_iambic.push prop.name_symbol
          end
        end
      end

      def render_property_description a, prop
        expag = expression_agent
        expag.current_property = prop
        a.concat prop.under_expression_agent_get_N_desc_lines expag ; nil
      end

      def populate_option_parser_with_universal_options op
      end

      def write_full_syntax_strings y
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
        help = to_full_inferred_prop_strm.each.detect do |prop|
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
        @output_iambic = []  # :+#public-API (name)
        @seen_h = {}
        @bound_call = nil
      end

      def parse_options
        @op ||= option_parser
        @op.parse! argv
        nil
      rescue ::OptionParser::ParseError => e
        resolve_bound_call_when_parse_error e ; nil
      end

      def option_parser
        help_renderer.op
      end

      def bound_call_class_via_option_property_name_i i
        m_i = :"bound_call_class_for_#{ i }_option"
        if respond_to? m_i
          send m_i
        else
          i_ = Callback_::Name.via_variegated_symbol( i ).as_const
          CLI_::When_.const_get( i_, false )
        end
      end

      def resolve_bound_call_when_parse_error e
        @bound_call = CLI_::When_::Parse_Error.new e, help_renderer
      end

      def expression_agent
        @partitions.expression_agent
      end

      def partitions
        @partitions
      end

      def properties
        @front_properties
      end

      def stderr
        @resources.serr
      end

      def help_renderer
        @partitions.help_renderer
      end

    private

      def argv
        @resources.argv
      end
    end

    Option_parser__ = Callback_.memoize do
      require 'optparse'
      ::OptionParser
    end

    # ~

    class Build_partitions__

      Actor_.call self, :properties, :scn, :adapter

      def execute
        Partitions__.new do |p|
          @adapter.receive_partitions p
          @partitions = p
          work
        end
        @partitions
      end

      def work

        @arg_a = @env_a = @opt_a = @many_a = nil

        d = 0 ; @original_index = {}

        while prop = @scn.gets

          @original_index[ prop.name_symbol ] = ( d += 1 )

          if prop.can_be_from_environment
            ( @env_a ||= [] ).push prop
          end

          prop.is_hidden and next

          _is_effectively_required = if prop.is_required
            if prop.has_default
              false  # explained fully at [#006]
            else
              true
            end
          end

          if _is_effectively_required
            ( @arg_a ||= [] ).push prop
          elsif prop.takes_many_arguments
            ( @many_a ||= [] ).push prop
          else
            ( @opt_a ||= [] ).push prop
          end
        end
        if @many_a
          determine_placement_for_many
        end
        maybe_make_experimental_aesthetic_readjustment
        @partitions.adapter = @adapter
        @partitions.arg_a = @arg_a.freeze
        @partitions.env_a = @env_a.freeze
        @partitions.opt_a = @opt_a.freeze ; nil
      end
    private
      def maybe_make_experimental_aesthetic_readjustment  # #note-575
        if ! @many_a && @opt_a && ( ! @arg_a || @opt_a.last.takes_argument  ) # (a), (b) and (c)
          make_experimental_aestethic_adjustment
        end
      end

      def make_experimental_aestethic_adjustment  # #note-600
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

      def determine_placement_for_many  # #note-600
        if @arg_a
          @arg_a.push @many_a.pop
          re_order @arg_a
        else
          @arg_a = [ @many_a.pop ]
        end
        if @many_a.length.nonzero?
          @opt_a.concat @many_a
          re_order @opt_a
        end
        @many_a = true
      end

      def re_order a
        a.sort_by! do |prop|
          @original_index.fetch prop.name_symbol
        end ; nil
      end
    end

    class Partitions__
      def initialize
        @expression_agent = @op = @help_renderer = nil
        yield self
        @expression_agent or resolve_expression_agent
        @op or resolve_option_parser
        @help_renderer or resolve_help_renderer
      end
      attr_accessor :opt_a, :arg_a, :env_a
      attr_accessor :adapter
      attr_reader :expression_agent, :help_renderer, :partitions
    private

      def resolve_expression_agent
        @expression_agent = @adapter.expression_agent_class.new self ; nil
      end

      def resolve_option_parser
        op = @adapter.option_parser_class.new
        @opt_a and @adapter.populate_option_parser_with_generated_opts op, @opt_a
        @adapter.populate_option_parser_with_universal_options op
        @op = op ; nil
      end

      def resolve_help_renderer
        CLI_::Action_Adapter_::Help_Renderer.new @op, @adapter; nil
      end

    public def receive_help_renderer o
        @help_renderer = o
        @opt_a and add_option_section o
        @arg_a and add_arg_section o
        @env_a and add_env_section o
      end

      def add_option_section o
        o.add_section :ad_hoc_section, 'options' do |help|
          help.output_option_parser_summary
        end
      end

      def add_arg_section o
        o.arg_a = @arg_a
        o.add_section :item_section, 'argument', @arg_a ; nil
      end

      def add_env_section o
        o.add_section :item_section, 'environment variable', @env_a do | prp |
          adapter.environment_variable_name_string_via_property prp
        end
      end

    public

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
        :is_required

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
      def initialize output_iambic, props
        scn = Callback_::Iambic_Stream.via_array output_iambic
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
      def complete env, argv
        @argv = argv ; @env = env ; freeze ; nil
      end
      def invocation_s_a
        @s_a
      end
    end

    class Aggregate_Bound_Call__ < Simple_Bound_Call_
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

      def resolve_properties

        @mutable_back_properties = nil
        @mutable_front_properties = nil

        @back_properties = @bound.formal_properties  # nil ok

        if @back_properties
          if @back_properties.has_name :config_filename
            _mutate_config_filename_properties
          end

          if @back_properties.has_name :max_num_dirs
            _mutate_max_num_dirs_properties
          end

          if @back_properties.has_name :workspace_path
            _mutate_workspace_path_properties
          end
        end

        @front_properties ||= @back_properties

        nil
      end

    private

      def _mutate_config_filename_properties

        # exclude this formal property from the front. leave back as-is.

        mutable_front_properties.remove :config_filename
      end

      def _mutate_max_num_dirs_properties

        # exclude this formal property from the front. in back, unbound it.

        mutable_front_properties.remove :max_num_dirs
        mutable_back_properties.replace_by :max_num_dirs do | prp |
          prp.without_default
        end

      end

      def _mutate_workspace_path_properties

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

        def _mutate_max_num_dirs_properties
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
