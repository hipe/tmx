module Skylab::Brazen

  class CLI < ::Class.new ::Class.new  # see [#002]

    class << self

      def expression_agent
        CLI::Expression_Agent__
      end

      alias_method :new_top_invocation, :new
      def new * a
        new_top_invocation Brazen_, * a
      end

      def pretty_path x
        expression_agent.pretty_path x
      end
    end

    Top_Invocation__ = self

    Branch_Invocation__ = Top_Invocation__.superclass

    Invocation__ = Branch_Invocation__.superclass

    class Top_Invocation__

      def initialize * a
        @env = nil
        @mod = a.first
        @resources = Resources__.new a
      end
      attr_writer :env
      def invoke argv
        @resources.complete @env || ::ENV, argv
        resolve_app_kernel
        resolve_properties
        resolve_partitions
        resolve_bound_call
        es =
        @bound_call.receiver.send @bound_call.method_name, * @bound_call.args
        flush_any_invitations
        es or @exit_status
      end
    private
      def call_bound_call exe
        exe.receiver.send exe.method_name, * exe.args
      end
      def resolve_app_kernel
        @app_kernel = @mod.const_get( :Kernel_, false ).new @mod ; nil
      end

    public

      def action
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
        Callback_::Name.from_module( @mod ).as_slug  # etc.
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

      def expression_agent_class
        self.class.const_get :Expression_Agent__, false
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
            i_a = adapter.action.class.full_name_function.map( & :as_lowercase_with_underscores_symbol )
            seen_general_h.fetch i_a do
              seen_general_h[ i_a ] = true
              adapter.output_invite_to_general_help
            end
          end
        end.clear
      end
    end

    # ~

    class Branch_Invocation__ < Invocation__

      def resources
        @resources
      end

    private
      def resolve_properties
        @properties = Properties__.new
      end
      def resolve_partitions
        @partitions = Build_partitions__[ get_full_inferred_props_scan, self ]
      end
      def get_full_inferred_props_scan
        scn = @properties.to_scan
        scn.push_by STANDARD_ACTION_PROPERTY_BOX__.fetch :ellipsis
      end
    public

      def receive_no_matching_action tok
        @token = tok
        resolve_bound_call_when_no_matching_action
        call_bound_call @bound_call
      end

      def receive_multiple_matching_adapters aa_a
        self._DO_ME
      end

    private

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
        @bound_call = CLI::When_::No_Arguments.new action_prop, help_renderer
      end
      def action_prop
        @properties.fetch :action
      end
      def resolve_bound_call_when_looks_like_action_for_first_argument
        @token = @resources.argv.shift
        @adapter_a = find_matching_action_adapters_with_token @token
        case 1 <=> @adapter_a.length
        when  0 ; resolve_bound_call_when_one_matching_adapter
        when  1 ; resolve_bound_call_when_no_matching_action
        when -1 ; resolve_bound_call_when_multiple_matching_adapters
        end     ; nil
      end

    public

      def retrieve_bound_action_via_normalized_name i_a
        retrieve_bound_action_via_normalized_name_scan(
          Lib_::Iambic_scanner[].new 0, i_a )
      end

      def retrieve_bound_action_via_normalized_name_scan xa_scan
        scn = get_action_scn
        i = xa_scan.gets_one
        while action = scn.gets
          if i == action.name.as_lowercase_with_underscores_symbol
            found = action
            break
          end
        end
        if found
          found.receive_frame self
          if xa_scan.unparsed_exists
            found.retrieve_bound_action_via_normalized_name_scan xa_scan
          else
            found
          end
        else
          raise ::KeyError, "not found: '#{ i }'"
        end
      end

      def find_matching_action_adapters_with_token tok
        a = find_matching_action_classes_with_token tok
        a.map! do |cls|
          bld_adapter_via_action action.action_via_action_class cls
        end
        a
      end

      def find_matching_action_classes_with_token tok
        matching_actions = [] ; rx = /\A#{ ::Regexp.escape tok }/
        scn = self.action.get_unbound_action_scan
        while action = scn.gets
          slug = action.name_function.as_slug
          if rx =~ slug
            if tok == slug
              matching_actions.clear.push action
              break
            end
            matching_actions.push action
          end
        end
        matching_actions
      end

      def get_action_scn
        scan = action.get_action_scan
        scan and scan.map_by( & method( :bld_adapter_via_action ) )
      end

      def bld_adapter_via_action action
        if action.is_branch
          branch_class.new action
        else
          action.accept_parent_node self.action
          leaf_class.new action
        end
      end

      def wrap_scanner_with_ordering_buffer scn
        CLI::Actors__::Via_after_produce_ordered_scanner[ scn ]
      end

      def leaf_class
        Action_Adapter__
      end

      def branch_class
        Branch_Adapter__
      end

    private
      def resolve_bound_call_when_no_matching_action
        @bound_call = CLI::When_::No_Matching_Action.new @token, help_renderer, self
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
        a = [] ; scn = to_actual_parameters_scanner
        scn.next
        begin
          i, x = scn.pair
          cls = bound_call_class_via_option_property_name_i i
          a.push cls.new( x, help_renderer, self )
        end  while scn.next
        @bound_call = Aggregate_Bound_Call__.new a
      end
      def to_actual_parameters_scanner
        Actual_Parameter_Scanner__.new @output_iambic, @properties
      end
      def resolve_bound_call_when_multiple_matching_adapters
        @bound_call = CLI::When_::Ambiguous_Matching_Actions.new self._TODO
      end
      def resolve_bound_call_when_one_matching_adapter
        adapter = @adapter_a.first
        adapter.receive_frame self
        @bound_call = adapter.via_argv_resolve_some_bound_call
      end
    end

    # ~

    Adapter_Methods__ = ::Module.new

    class Action_Adapter__ < Invocation__

      include Adapter_Methods__

    private
      def resolve_properties
        @properties = if @action.class.respond_to? :properties
          @action.class.properties
        end ; nil
      end
      def resolve_partitions
        @partitions = Build_partitions__[ get_full_inferred_props_scan, self ]
      end
      def get_full_inferred_props_scan
        scan = if @properties
          @properties.to_scan
        else
          Scan_[].nonsparse_array EMPTY_A_
        end
        scan.push_by STANDARD_ACTION_PROPERTY_BOX__.fetch :help
      end
    public
      def receive_show_help otr
        receive_frame otr
        help_renderer.output_help_screen
        SUCCESS_
      end
    private
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
          a.push CLI::When_::Unhandled_Arguments.
            new argv, help_renderer
        end
        @bound_call = Aggregate_Bound_Call__.new a
      end
    public def bound_call_class_for_help_option
        When_Action_Help__
      end
      def resolve_bound_call_when_any_args
        arg_a = @partitions.arg_a || EMPTY_A_
        @arg_parse = Action_Adapter_::Arguments.new argv, arg_a
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
        @bound_call = CLI::When_::Missing_Arguments.new ev, help_renderer
      end
      def resolve_bound_call_when_extra_arguments ev
        @bound_call = CLI::When_::Extra_Arguments.new ev, help_renderer
      end

      def resolve_bound_call_when_ARGV_parsed
        @output_iambic.concat @arg_parse.release_result_iambic
        @partitions.env_a and process_environment
        @bound_call or resolve_bound_call_via_output_iambic
      end

      def process_environment
        env = @resources.env
        @partitions.env_a.each do |prop|
          s = env[ prop.upcase_environment_name_i.id2name ]
          s or next
          cased_i = prop.name_i.downcase  # [#039] casing
          @seen_h[ cased_i ] and next
          @output_iambic.push cased_i, s
        end ; nil
      end

      def resolve_bound_call_via_output_iambic
        @bound_call = @action.bound_call_via_call @output_iambic, self
        @bound_call or self._SANITY
        nil
      end

    public
      def app_name
        @parent.app_name
      end

      Autoloader_[ self ]
    end

    class Simple_Bound_Call_
      def receiver
        self
      end

      def method_name
        :produce_any_result
      end

      def args
      end
    end

    class When_Action_Help__ < Simple_Bound_Call_

      def initialize _, help_renderer, _action_adapter
        @help_renderer = help_renderer
        _ and self._SANITY
      end
      def produce_any_result
        @help_renderer.output_help_screen
        SUCCESS_
      end
    end

    class Branch_Adapter__ < Branch_Invocation__

      include Adapter_Methods__

      def receive_show_help otr
        receive_frame otr
        CLI::When_::Help.new( nil, help_renderer, self ).produce_any_result
      end
    end

    module Adapter_Methods__

      def initialize action
        @action = action
      end

      def name
        @action.name
      end

      def is_visible
        @action.is_visible
      end

      def has_description
        @action.has_description
      end

      def under_expression_agent_get_N_desc_lines exp, d=nil
        @action.under_expression_agent_get_N_desc_lines exp, d
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

      def action
        @action
      end

      def action_adapter
        self
      end

      def invocation
        self
      end

      def retrieve_bound_action_via_normalized_name i_a
        @parent.retrieve_bound_action_via_normalized_name i_a
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

      def receive_event ev
        ev_ = ev.to_event
        if ev_.has_tag :ok
          if ev_.ok
            if ev_.has_tag :is_completion and ev_.is_completion
              receive_completion_event ev
            elsif ev.verb_lexeme
              receive_positive_event ev
            else
              receive_payload_event ev
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
        _a = render_event_lines ev
        send_payload_event_lines _a
        maybe_use_exit_status_via_OK_or_not_OK_event ev
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
        v_s = ev.inflected_verb
        lex = ev.noun_lexeme and n_s = lex.lemma
        prefix = "couldn't #{ [ v_s, n_s ].compact * SPACE_ } because "
        "#{ open }#{ prefix }#{ inside }#{ close }"
      end

      def maybe_inflect_line_for_completion_via_event s, ev
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
        Brazen_::Lib_::Text[].unparenthesize_message_string s
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
        @redundancy_filter ||= CLI::Redundancy_Filter__.new
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

      public def maybe_use_exit_status d
        @parent.maybe_use_exit_status d
      end
    end

    # ~

    class Invocation__

      def option_parser_class
        CLI::Lib_::Option_parser[]
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
          letter = h[ prop.name_i ]
          letter and args.push "-#{ letter }"
          base = "--#{ prop.name.as_slug }"
          if prop.takes_argument
            if prop.argument_is_required
              args.push "#{ base } #{ argument_label_for prop }"
            else
              args.push "#{ base } [#{ argument_label_for prop }]"
            end
            p = -> x do
              @seen_h[ prop.name_i ] = true
              @output_iambic.push prop.name_i, x
            end
          else
            args.push base
            p = -> _ do
              @seen_h[ prop.name_i ] = true
              @output_iambic.push prop.name_i
            end
          end
          prop.has_description and render_property_description args, prop
          op.on( * args, & p )
        end ; nil
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
        help = get_full_inferred_props_scan.each.detect do |prop|
          :help == prop.name_i
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

      def prepare_to_parse_parameters
        @bound_call = nil ; @output_iambic = [] ; @seen_h = {}
      end

      def parse_options
        @op ||= option_parser
        @op.parse! argv ; nil
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
          i_ = Callback_::Name.from_variegated_symbol( i ).as_const
          CLI::When_.const_get( i_, false )
        end
      end

      def resolve_bound_call_when_parse_error e
        @bound_call = CLI::When_::Parse_Error.new e, help_renderer
      end

      def expression_agent
        @partitions.expression_agent
      end

      def partitions
        @partitions
      end

      def properties
        @properties
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

    # ~

    class Build_partitions__
      Actor_[ self, :properties, :scn, :kernel ]
      def execute
        Partitions__.new do |p|
          @kernel.receive_partitions p
          @partitions = p
          work
        end
        @partitions
      end
      def work
        @arg_a = @env_a = @opt_a = @many_a = nil
        d = 0 ; @original_index = {}
        while prop = @scn.gets
          @original_index[ prop.name_i ] = ( d += 1 )
          if prop.can_be_from_environment
            ( @env_a ||= [] ).push prop
          end
          prop.can_be_from_argv or next
          if prop.is_actually_required
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
        @partitions.kernel = @kernel
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
          STANDARD_BRANCH_PROPERTY_BOX__.has_name( prop.name_i ) and next
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
          @original_index.fetch prop.name_i
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
      attr_accessor :kernel
      attr_reader :expression_agent, :help_renderer, :partitions
    private

      def resolve_expression_agent
        @expression_agent = @kernel.expression_agent_class.new self ; nil
      end

      def resolve_option_parser
        op = @kernel.option_parser_class.new
        @opt_a and @kernel.populate_option_parser_with_generated_opts op, @opt_a
        @kernel.populate_option_parser_with_universal_options op
        @op = op ; nil
      end

      def resolve_help_renderer
        CLI::Action_Adapter_::Help_Renderer.new @op, @kernel ; nil
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
        o.add_section :item_section, 'environment variable',
          @env_a, & :upcase_environment_name_i
      end

    public

      def rendering_method_name_for prop  # for expag
        category_i, = lookup_property prop
        :"render_prop_as_#{ category_i }"
      end

    private

      def lookup_property prop
        i = prop.name_i
        if opt = option_via_name( i )
          [ :option, opt ]
        elsif arg = argument_via_name( i )
          [ :argument, arg ]
        elsif env = environment_variable_via_name( i )
          [ :environment_variable, env ]
        else
          [ :unknown, prop ]
        end
      end

      def option_via_name i
        any_i_in_a i, @opt_a
      end

      def argument_via_name i
        any_i_in_a i, @arg_a
      end

      def environment_variable_via_name i
        any_i_in_a i, @env_a
      end

      def any_i_in_a i, a
        if a
          a.detect do |o|
            i == o.name_i
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
          h[ prop.name_i ] = name_s[ 0, 1 ]
        when 2
          h.delete prop.name_i
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
      def to_scan
        scn = @box.to_value_scanner
        Scan_[].new do
          scn.gets
        end
      end
    end

    class Property__
      def initialize name_i, * x_a
        @argument_arity = :one
        @custom_moniker = nil
        @desc = nil
        @can_be_from_argv = true
        @name = Callback_::Name.from_variegated_symbol name_i
        x_a.each_slice( 2 ) do |i, x|
          instance_variable_set :"@#{ i }", x
        end
        freeze
      end
      attr_reader :desc, :name,
        :argument_arity,
        :argument_moniker,
        :can_be_from_argv,
        :can_be_from_environment,
        :custom_moniker,
        :is_required

      alias_method :is_actually_required, :is_required

      def name_i
        @name.as_variegated_symbol
      end

      def has_custom_moniker
        @custom_moniker
      end

      def has_description
        @desc
      end

      def under_expression_agent_get_N_desc_lines expag, d=nil
        Brazen_::Lib_::N_lines[].new( [], d, [ @desc ], expag ).execute
      end

      def takes_argument  # zero to many takes argument
        :zero != @argument_arity
      end

      def argument_is_required
        :one == @argument_arity or :one_to_many == @argument_arity
      end

      def takes_many_arguments
        :zero_to_many == @argument_arity or :one_to_many == @argument_arity
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
        # :argument_arity, :zero_to_many,
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
        scn = Lib_::Iambic_scanner[].new 0, output_iambic
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
      def initialize a
        @mod, @sin, @sout, @serr, @s_a = a
        if @s_a
          @s_a.last.nil? and @s_a[ -1 ] = Callback_::Name.from_module( @mod ).as_slug
        else
          @s_a = [ ::File.basename( $PROGRAM_NAME ) ].freeze
        end
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
      def produce_any_result
        scn = Scan_[].nonsparse_array @a
        while exe = scn.gets
          value = exe.receiver.send exe.method_name, * exe.args
          value.nonzero? and break
        end
        value
      end
    end

    module Lib_
      Iambic_scanner = Brazen_::Lib_::Iambic_scanner
      Option_parser = -> do
        require 'optparse'
        ::OptionParser
      end
    end

    DASH_BYTE_ = '-'.getbyte 0
    GENERIC_ERROR_ = 5
    NOTHING_ = nil
    SUCCESS_ = 0
  end
end
