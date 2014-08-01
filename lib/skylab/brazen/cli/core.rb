module Skylab::Brazen

  module CLI

    def self.new *a
      CLI::Client__.new( *a )
    end

    # ~ main CLI hand-made implementation

    class Client__

      def initialize i, o, e, mutable_invocation_string_parts=nil
        init_mutable_invocation_string_parts mutable_invocation_string_parts
        @stdout = o ; @stderr = e
      end
    private
      def init_mutable_invocation_string_parts a
        a && a.last.nil? and a[ a.length - 1 ] = "brazen"  # bugfix for 'tmx -h'
        a ||= [ $PROGRAM_NAME ]
        @invocation_str_a = a.freeze ; nil
      end
    public

      def invoke argv
        @argv = argv
        if argv.length.nonzero? && DASH__ != argv.first.getbyte( 0 )
          invoke_when_action_argument
        else
          invoke_when_no_action_argument
        end
      end

      DASH__ = '-'.getbyte 0

    private

      def invoke_when_no_action_argument
        if @argv.length.zero?
          invoke_when_no_arguments
        else
          invoke_when_options
        end
      end

      def invoke_when_no_arguments
        CLI::When_::No_Arguments.new( self ).execute  # read [#003]
      end

      def invoke_when_options
        processors = []
        o = CLI::Lib_::Option_parser[].new
        o.on '-h', '--help [cmd]', "this screen" do |cmd|
          processors.push when_help( o, cmd )
        end
        begin
          o.parse! @argv
        rescue ::OptionParser::ParseError => e
          processors.push when_parse_error e
        end
        @argv.length.nonzero? and processors.push when_unhanded_arguments
        while (( processor = processors.shift ))
          last_exit_status = processor.execute
          last_exit_status.zero? and break
        end
        last_exit_status
      end

      def when_help op, cmd
        CLI::When_::Help.new op, cmd, self
      end

      def when_parse_error e
        CLI::When_::Parse_Error.new e, help_renderer
      end

      def when_unhanded_arguments
        CLI::When_::Unhandled_Arguments.new @argv, self
      end

      def invoke_when_action_argument
        matching_actions = find_matching_actions_with_token @argv.shift
        case matching_actions.length
        when 0 ; invoke_when_no_matching_action
        when 1 ; matching_actions.first.invoke_via_argv @argv
        else   ; invoke_when_ambiguous_matching_actions
        end
      end

    public  # ~ interface for agents

      attr_reader :stderr

      def find_matching_actions_with_token tok
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

      def invoke_when_no_matching_action
        CLI::When_::No_Matching_Action.new( @token, self ).execute
      end

      def invoke_when_ambiguous_matching_actions
        CLI::When_::Ambiguous_Matching_Actions.new( @token, self ).execute
      end

      def help_renderer
        @hlp_rndrr ||= CLI::Action_Adapter_::Help_Renderer.
          new self, nil, nil, self
      end

      def expression_agent
        @expr_ag ||= CLI::Expression_Agent__.new
      end

      def render_syntax_string
        expression_agent.calculate { "#{ par 'action' } [..]" }
      end

      def invocation_string
        @invocation_str_a * SPACE_
      end

      def name
        @name ||= Callback_::Name.from_variegated_symbol(
          @invocation_str_a.last.intern )
      end

      # ~ for ad-hoc facet agents

      def when_extra_ARGV_arguments_event ev, action_adapter
        CLI::When_::Extra_Arguments.
          new( ev, action_adapter, self ).execute
      end

      def when_missing_ARGV_arguments_event ev, action_adapter
        CLI::When_::Missing_Arguments.
          new( ev, action_adapter, self ).execute
      end

      # ~ deep API for agents

      def actions
        @actions ||= Actions__.new krnl, self
      end

    private
      def krnl
        @kernel ||= Brazen_::Kernel_.new( Brazen_, @invocation_str_a.last )
      end
    end

    class Actions__
      def initialize krnl, client
        @client = client ; @kernel = krnl
      end
      def visible
        self
      end
      def to_a
        a = [] ; scn = get_scanner ; r = nil
        a.push r while r = scn.gets ; a
      end
      def get_scanner
        Brazen_::Scanner_::Wrapper.new @kernel.get_action_scanner do |action|
          Action_Adapter_.new action, @client
        end
      end
    end

    class Action_Adapter_

      def initialize action, client
        @action = action ; @client = client
        @hr = nil
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

      def set_help_renderer hr
        @hr = hr
      end

      def render_syntax_string
        @hr.produce_main_syntax_string
      end

      def invoke_via_argv argv
        x, method_i, args =
          Action_Adapter_::Parse_ARGV.new( @client, self, argv ).execute
        if method_i
          x.send method_i, * args
        else
          x || GENERIC_ERROR_
        end
      end

      def invoke_via_iambic x_a
        @exit_status = nil
        @action.invoke_via_iambic_and_client_adapter x_a, self
        @exit_status
      end

      def on_error_channel_entity_structure ev
        ev.render_all_lines_into_under @hr.y, @client.expression_agent
        @hr.output_invite_to_general_help
        @exit_status = rslv_some_exit_status_via_event_structure ev
        nil
      end

    private

      def rslv_some_exit_status_via_event_structure ev
        if ev.has_member :error_code then ev.error_code else
          Brazen_::API.any_error_code_via_terminal_channel_i(
            ev.terminal_channel_i ) || GENERIC_ERROR_
        end
      end

      Autoloader_[ self ]
    end

    class Expression_Agent__

      alias_method :calculate, :instance_exec

      def s x
        x.respond_to?( :length ) and x = x.length
        's' if x.nonzero?
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

      def par x  # make the string or prop look like a parameter (placeholder)
        _string = x.respond_to?( :ascii_only? ) ? x : x.name.as_slug
        highlight "<#{ _string }>"
      end

      def stylize style_d_a, string
        "\e[#{ style_d_a.map( & :to_s ).join( ';' ) }m#{ string }\e[0m"
      end
    end

    module Lib_
      Option_parser = -> do
        require 'optparse'
        ::OptionParser
      end
    end

    GENERIC_ERROR_ = 5
    PROCEDE_ = nil
    SUCCESS_ = 0
    SPACE_ = ' '.freeze
    UNDERSCORE_ = '_'.freeze
  end
end
