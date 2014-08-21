module Skylab::Brazen

  module CLI

    class << self
      def new *a
        CLI::Invocation__.new( *a )
      end
      def pretty_path x
        Expression_Agent__.pretty_path x
      end
    end

    # ~ main CLI hand-made implementation

    class Invocation__

      def initialize i, o, e, mutable_invocation_string_parts=nil
        init_mutable_invocation_string_parts mutable_invocation_string_parts
        @stdout = o ; @stderr = e
        @environment = @op = nil
      end
      attr_writer :environment

      def init_mutable_invocation_string_parts a
        a && a.last.nil? and a[ a.length - 1 ] = "brazen"  # bugfix for 'tmx -h'
        a ||= [ $PROGRAM_NAME ]
        @invocation_str_a = a.freeze ; nil
      end

      def invoke argv
        @argv = argv
        @properties_adapter = Properties_Adapter__.new argv, self
        if @argv.length.zero?
          invoke_when_no_arguments
        elsif DASH__ == @argv.first.getbyte( 0 )
          invoke_when_options
        else
          adapter = adapter_when_action_token
          adapter && adapter.execution_receiver.execute
          @exit_status
        end
      end
      DASH__ = '-'.getbyte 0

    private  # ~ when no arguments

      def invoke_when_no_arguments
        _prop = props.fetch :action
        CLI::When_::No_Arguments.new( _prop, hlp_renderer ).execute  # [#003]
      end

      def props
        My_properties_model__[].properties
      end

      My_properties_model__ = -> do  # #experimental
        p = -> do
          x = class My_Properties_Model___
            Brazen_::Model_::Entity[ self, -> do
              o :required, :property, :action
            end ]
            self
          end
          p = -> { x } ; x
        end
        -> { p[] }
      end.call

      # ~ when options (,the stock option parser)

      def invoke_when_options
        o = get_op_p.call ; processors = @processors
        begin
          o.parse! @argv
        rescue ::OptionParser::ParseError => e
          processors.push when_parse_error e
        end
        @argv.length.nonzero? and processors.push when_unhanded_arguments
        while (( processor = processors.shift ))
          last_exit_status = processor.execute
          last_exit_status.nonzero? and break
        end
        last_exit_status
      end

      def get_op_p
        -> { @op || init_op ; @op }
      end

      def init_op
        processors = []
        o = CLI::Lib_::Option_parser[].new
        o.on '-h', '--help [cmd]', "this screen" do |cmd_s|
          processors.push when_help cmd_s
        end
        @op = o ; @processors = processors; nil
      end

      def when_help cmd_s
        CLI::When_::Help.new cmd_s, hlp_renderer, self
      end

      def when_parse_error e
        CLI::When_::Parse_Error.new e, hlp_renderer
      end

      def when_unhanded_arguments
        CLI::When_::Unhandled_Arguments.new @argv, hlp_renderer
      end

      def hlp_renderer
        @properties_adapter.help_renderer
      end
    end

    # ~ interlude: tons of support classes

    class Properties_Adapter__

      def initialize argv, invocation, action_adapter=nil
        _kernel = Kernel__.new argv, action_adapter, invocation
        @parse_context = Parse_Context__.new _kernel
      end

      def expression_agnt
        @parse_context.expression_ag
      end

      def help_renderer
        @parse_context.help_renderer
      end

      attr_reader :parse_context

      class Kernel__

        def initialize argv, action_adapter, invocation
          @action_adapter = action_adapter
          @argv = argv
          @invocation = invocation
          _scn = ( action_adapter || invocation ).get_property_scanner
          @partitions = Partitions__.new _scn
        end

        attr_reader :action_adapter, :argv, :invocation, :partitions

        def action
          ( @action_adapter || @invocation ).action
        end

        def expression_agent
          @expag ||= Expression_Agent__.new @partitions
        end

        def any_option_parser_p
          ( @action_adapter || @invocation ).any_optparse_p
        end

        def stderr
          @invocation.stderr
        end
      end

      class Partitions__
        def initialize scn
          arg_a = env_a = opt_a = nil
          while (( prop = scn.gets ))
            if prop.can_be_from_environment
              ( env_a ||= [] ).push prop
            end
            prop.can_be_from_argv or next
            if prop.is_actually_required
              ( arg_a ||= [] ).push prop
            else
              ( opt_a ||= [] ).push prop
            end
          end
          # experimental aesthetics - fill the trailing optional arg "slot"
          if opt_a && ! arg_a && opt_a.last.has_default
            ( arg_a ||= [] ).push opt_a.pop
            opt_a.length.zero? and opt_a = nil
          end
          @opt_a = opt_a.freeze
          @arg_a = arg_a.freeze
          @env_a = env_a.freeze
          freeze
        end

        attr_reader :env_a, :opt_a, :arg_a

        def rendering_method_name_for prop
          if @opt_a and @opt_a.include? prop
            :render_prop_as_option
          elsif @arg_a and @arg_a.include? prop
            :render_prop_as_argument
          else
            @env_a && @env_a.include?( prop ) or fail "sanity: #{prop.name_i}"
            :render_prop_as_environment_variable
          end
        end
      end
    end

    class Invocation__  # ~ public API for nearby support classes

      # ~ for processors (the "when" classes)

      def find_matching_action_adapters_with_token s
        fnd_matching_action_adapters_with_token s
      end

      def invoke_when_no_matching_action
        invk_when_no_matching_action
      end

      def properties
        props
      end

      # ~ for parse context

      def environment
        @environment || ::ENV
      end

      # ~ for help renderer

      def invocation_string
        @invocation_str_a * SPACE_
      end

      def render_syntax_string
        prop = props.fetch :action
        expr_ag.calculate { "#{ par prop } [..]" }
      end
    private
      def expr_ag
        @properties_adapter.expression_agnt
      end
    public

      # ~ for kernel

      def action
        self
      end

      def any_optparse_p
        get_op_p
      end

      def get_property_scanner
        props.to_value_scanner
      end

      attr_reader :stderr
    end

    class Parse_Context__

      def initialize kernel
        @kernel = kernel
      end

      def expression_ag
        @kernel.expression_agent
      end

      def help_renderer
        @help_renderer ||= bld_help_renderer
      end

      def bld_help_renderer
        _op = prdc_some_option_parser
        Action_Adapter_::Help_Renderer.new _op, @kernel
      end

      def prdc_some_option_parser
        if (( op_p = @kernel.any_option_parser_p  ))
          op_p[]
        else
          bld_op
        end
      end

      def bld_op
        op = CLI::Lib_::Option_parser[].new
        opt_a = @kernel.partitions.opt_a
        opt_a and populate_option_parser_with_generated_options op, opt_a
        populate_option_parser_with_universal_options op
        op
      end

      def populate_option_parser_with_generated_options op, opt_a
        h = build_unique_letter_hash opt_a
        opt_a.each do |prop|
          args = []
          letter = h[ prop.name_i ]
          letter and args.push "-#{ letter }"
          base = "--#{ prop.name.as_slug }"
          p = -> x do
            @output_iambic.push prop.name_i, x
          end
          if prop.takes_argument
            args.push "#{ base } #{ argument_label_for prop }"
            p = -> x do
              @did_set_h[ prop.name_i ] = true
              @output_iambic.push prop.name_i, x
            end
          else
            args.push base
            p = -> _ do
              @did_set_h[ prop.name_i ] = true
              @output_iambic.push prop.name_i
            end
          end
          if prop.has_description
            args.concat prop.under_expression_agent_get_N_desc_lines(
              @kernel.expression_agent )
          end
          op.on( * args, & p )
        end ; nil
      end

      def build_unique_letter_hash opt_a
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

      def argument_label_for prop  # :+#hack
        prop.name.as_variegated_string.split( UNDERSCORE_ ).last.upcase
      end

      def populate_option_parser_with_universal_options op
        op.on '-h', '--help', 'this screen' do
          @help_renderer.output_help_screen
          @result = SUCCESS_
        end ; nil
      end
    end

    class Invocation__  # ~ when action token
    private

      def adapter_when_action_token
        matching_actions = fnd_matching_action_adapters_with_token @argv.shift
        case matching_actions.length
        when 0
          @exit_status = invk_when_no_matching_action
        when 1
          adapter = matching_actions.first.adapter_via_argv @argv
        else
          @exit_status = invoke_when_ambiguous_matching_actions
        end
        adapter
      end

      def fnd_matching_action_adapters_with_token tok
        @token = tok
        matching_actions = []
        rx = /\A#{ ::Regexp.escape tok }/
        scn = actions.get_scanner
        while (( action = scn.gets ))
          slug = action.name.as_slug
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

      def invk_when_no_matching_action
        CLI::When_::No_Matching_Action.new( @token, hlp_renderer, self ).execute
      end

      def invoke_when_ambiguous_matching_actions
        CLI::When_::Ambiguous_Matching_Actions.new( @token, self ).execute
      end

    public

      # ~ in support of above

      def ___name
        @name ||= Callback_::Name.from_variegated_symbol(
          @invocation_str_a.last.intern )
      end

      def set_exit_status d
        @exit_status = d ; nil
      end

      # ~ general client-related services for ad-hoc agents

      def app_name
        ::File.basename @invocation_str_a.last
      end

      # ~ deep API for mechanics agents

      def actions
        @actions ||= Actions__.new self, krnl
      end
    private
      def krnl
        @kernel ||= Brazen_::Kernel_.new( Brazen_, @invocation_str_a.last )
      end
    end

    class Actions__
      def initialize invocation, krnl
        @invocation = invocation ; @kernel = krnl
      end
      def visible
        self
      end
      def to_a
        a = [] ; scn = get_scanner ; r = nil
        a.push r while r = scn.gets ; a
      end
      def get_scanner
        Kernel_.wrap_scanner @kernel.get_action_scanner do |action|
          Action_Adapter_.new @invocation, action
        end
      end
    end

    class Action_Adapter_

      def initialize invocation, action
        @action = action ; @invocation = invocation
      end

      attr_reader :action

      def name
        @action.name
      end

      def has_description
        @action.has_description
      end

      def under_expression_agent_get_N_desc_lines exp, d=nil
        @action.under_expression_agent_get_N_desc_lines exp, d
      end

      def render_syntax_string
        hlp_rndrr.produce_main_syntax_string
      end

      # ~ for invocation

      def adapter_via_argv argv
        @properties_adapter = Properties_Adapter__.new argv, @invocation, self
        @properties_adapter.produce_the_adapter
      end

      def help_rndrr
        @properties_adapter.help_renderer
      end

      def execution_receiver
        @action
      end

      # ~ for parse context

      def adapter_via_iambic x_a
        @action.produce_adapter_via_iambic_and_adapter x_a, self
      end

      # ~ for kernel

      def get_property_scanner
        @action.get_property_scanner
      end

      def any_optparse_p  # in theory, a hook for building op manually
      end

      def stderr
        @invocation.stderr
      end

      # ~ for ad-hoc business agents

      def app_name
        @invocation.app_name
      end

      # ~

      def on_event ev
        ev_ = ev.to_event
        if ev_.has_tag :is_positive
          _ok = ev_.is_positive
          if _ok
            if ev_.has_tag :is_completion and ev_.is_completion
              on_completion_event ev
            else
              on_positive_event ev
            end
          else
            on_negative_event ev
          end
        else
          send_event ev
        end
      end

      def on_completion_event ev
        set_ext_status SUCCESS_
        a = render_event_lines ev
        s = maybe_inflect_line_for_completion_via_event a.first, ev
        s and a[ 0 ] = s
        send_non_payload_event_lines a
      end

      def on_positive_event ev
        ev_ = ev.to_event
        if ev_.is_positive
          set_ext_status SUCCESS_
        else
          set_ext_status some_err_code_for_event ev_
        end
        a = render_event_lines ev
        s = maybe_inflect_line_for_positivity_via_event a.first, ev
        s and a[ 0 ] = s
        send_non_payload_event_lines a
      end

      def on_negative_event ev
        set_ext_status some_err_code_for_event ev
        a = render_event_lines ev
        s = maybe_inflect_line_for_negativity_via_event a.first, ev
        s and a[ 0 ] = s
        send_non_payload_event_lines a
        hlp_rndrr.output_invite_to_general_help
      end

    private

      def send_event ev
        _a = render_event_lines ev
        send_non_payload_event_lines _a
      end

      def render_event_lines ev
        y = []
        ev.render_all_lines_into_under y, expr_agent
        y
      end

      def maybe_inflect_line_for_completion_via_event s, ev
        open, inside, close = unparenthesize s
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

      def maybe_inflect_line_for_positivity_via_event s, ev
        open, inside, close = unparenthesize s
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

      HACK_IS_ONE_WORD_RX__ = /\A[a-z]+\z/

      def maybe_inflect_line_for_negativity_via_event s, ev
        open, inside, close = unparenthesize s
        v_s = ev.inflected_verb ; n_s = ev.inflected_noun
        prefix = "couldn't #{ [ v_s, n_s ].compact * SPACE_ } because "
        "#{ open }#{ prefix }#{ inside }#{ close }"
      end

      def unparenthesize s
        Brazen_::Lib_::Text[].unparenthesize_message_string s
      end

      def send_non_payload_event_lines a
        _y = hlp_rndrr.y
        a.each do |line|
          _y << line
        end ; nil
      end

      def expr_agent
        @properties_adapter.expression_agnt
      end

      def hlp_rndrr
        @properties_adapter.help_renderer
      end

      def set_ext_status d
        @invocation.set_exit_status d ; nil
      end

      def some_err_code_for_event ev
        any_err_code_for_event( ev ) || GENERIC_ERROR_
      end

      def any_err_code_for_event ev
        any_ext_status_for_chan_i ev.terminal_channel_i
      end

      def some_ext_status_for_chan_i i
        Brazen_::API.exit_statii.fetch i
      end

      def any_ext_status_for_chan_i i
        Brazen_::API.exit_statii[ i ]
      end

      Autoloader_[ self ]
    end

    class Properties_Adapter__  # ~ produce the adapter
      def produce_the_adapter
        @parse_context.produce_adapter
      end
    end

    class Parse_Context__  # ~ produce adapter (that is, parse everything)

      def produce_adapter
        @argv = @kernel.argv ; @did_set_h = {} ; @output_iambic = []
        _op = help_renderer.op
        result = parse_options _op
        result ||= parse_arguments
        result ||= process_environment
        if result
          @kernel.invocation.set_exit_status result
          NOTHING_
        else
          @kernel.action_adapter.adapter_via_iambic @output_iambic
        end
      end

    private  # ~ parse options

      def parse_options op
        @result = PROCEDE_
        op.parse! @argv
        @result
      rescue ::OptionParser::ParseError => e
        CLI::When_::Parse_Error.new( e, help_renderer ).execute
      end

      # ~ parse arguments

      def parse_arguments
        _arg_a = @kernel.partitions.arg_a || EMPTY_A_
        parse = Action_Adapter_::Arguments.new @argv, _arg_a
        error_event = parse.execute
        if error_event
          _meth_i = ARGV_ERROR_OP_H__.fetch error_event.event_channel_i
          @kernel.invocation.send(
            _meth_i, error_event, @kernel.action_adapter )
        else
          _x_a = parse.release_result_iambic
          @output_iambic.concat _x_a
          PROCEDE_
        end
      end

      EMPTY_A_ = [].freeze

      ARGV_ERROR_OP_H__ = {
        extra: :when_extra_ARGV_arguments_event,
        missing: :when_missing_ARGV_arguments_event
      }.freeze

      # ~ process environment

      def process_environment
        @env_a = @kernel.partitions.env_a
        @env_a and whn_env_a_prcss_environment
      end

      def whn_env_a_prcss_environment
        env = @kernel.invocation.environment
        @env_a.each do |prop|
          @did_set_h[ prop.name_i ] and next
          prop.environment_name_i
          s = env[ prop.environment_name_i ]
          s or next
          @output_iambic.push prop.name_i, s
        end
        PROCEDE_
      end
    end

    class Invocation__  # ~ produce the adapter

      def when_extra_ARGV_arguments_event ev, action_adptr
        CLI::When_::Extra_Arguments.new( ev, action_adptr.help_rndrr ).execute
      end

      def when_missing_ARGV_arguments_event ev, action_adptr
        CLI::When_::Missing_Arguments.new( ev, action_adptr.help_rndrr ).execute
      end
    end

    class Expression_Agent__

      def self.pretty_path x
        self::Pretty_Path__.new( x ).execute
      end

      def initialize partitions
        @partitions = partitions
      end

      alias_method :calculate, :instance_exec

      def s x
        x.respond_to?( :length ) and x = x.length
        's' if 1 != x
      end

      GREEN__ = 32
      STRONG__ = 1

      def code string
        "'#{ stylize CODE_STYLE__, string }'"
      end
      CODE_STYLE__ = [ GREEN__ ].freeze

      def hdr string
        stylize HIGHLIGHT_STYLE__, "#{ string }:"
      end

      def highlight string
        stylize HIGHLIGHT_STYLE__, string
      end
      HIGHLIGHT_STYLE__ = [ STRONG__, GREEN__ ].freeze

      def ick s
        code s
      end

      def par prop
        _unstyled = send @partitions.rendering_method_name_for( prop ), prop
        highlight _unstyled
      end

      def render_prop_as_option prop
        "--#{ prop.name.as_slug }"
      end

      def render_prop_as_argument prop
        "<#{ prop.name.as_slug }>"
      end

      def render_prop_as_environment_variable prop
        prop.environment_name_i
      end

      def pth s
        if s.respond_to? :to_path
          s = s.to_path
        end
        if DIR_SEP__ == s.getbyte( 0 )
          self.class::Pretty_Path__.new( s ).execute
        else
          s
        end
      end
      DIR_SEP__ = '/'.getbyte 0

      def stylize style_d_a, string
        "\e[#{ style_d_a.map( & :to_s ).join( ';' ) }m#{ string }\e[0m"
      end

      Autoloader_[ self ]
    end

    module Lib_
      Option_parser = -> do
        require 'optparse'
        ::OptionParser
      end
    end

    GENERIC_ERROR_ = 5
    NOTHING_ = PROCEDE_ = nil
    SUCCESS_ = 0
  end
end
