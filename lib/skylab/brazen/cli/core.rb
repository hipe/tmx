module Skylab::Brazen

  module CLI

    def self.new *a
      CLI::Client__.new( *a )
    end

    # ~ #comport:face

    module Client
      module Adapter
        module For
          module Face
            module Of
              module Hot
                def self.[] kernel, token
                  Client__
                end
              end
            end
          end
        end
      end
    end

    class Client__

      def self.call kernel, token
        a = kernel.get_normal_invocation_string_parts ; a.push token
        Client__.new( * kernel.three_streams, a )
      end

      def pre_execute
        self
      end

      def is_autonomous
        true
      end

      def get_autonomous_quad argv
        [ self, :invoke, [ argv ], nil ]  # receiver, method, args, block
      end

      def is_visible
        true
      end

      def get_summary_a_from_sheet sht
      end
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
          CLI::State_Processors_::When_No_Arguments.new( self ).execute
        else
          invoke_when_options
        end
      end

      def invoke_when_options
        require 'optparse'
        processors = []
        o = ::OptionParser.new
        o.on '-h', '--help [cmd]', "this screen" do |cmd|
          processors.push(
            CLI::State_Processors_::When_Help.new o, cmd, self )
        end
        last_exit_status = nil
        begin
          o.parse! @argv
        rescue ::OptionParser::ParseError => e
          processors.push(
            CLI::State_Processors_::When_Parse_Error.new e, self )
        end
        unless last_exit_status
          @argv.length.nonzero? and
            processors.push(
              CLI::State_Processors_::When_Extra_Args.new @argv, self )
          while (( processor = processors.shift ))
            last_exit_status = processor.execute
            last_exit_status.zero? and break
          end
        end
        last_exit_status
      end


      def invoke_when_action_argument
        @token = @argv.shift
        matching_actions = []
        rx = /\A#{ ::Regexp.escape @token }/
        scn = get_action_scanner
        while (( action = scn.gets ))
          slug = action.name.as_slug
          if rx =~ slug
            if @token == slug
              matching_actions.clear.push action
              break
            end
            matching_actions.push action
          end
        end
        case matching_actions.length
        when 0 ; whn_no_matching_action
        when 1 ; matching_actions.first.invoke @argv
        else   ; whn_ambiguous_matching_actions
        end
      end

      def whn_no_matching_action
        CLI::State_Processors_::When_No_Matching_Action.
          new( @token, self ).execute
      end

      def whn_ambiguous_matching_actions
        CLI::State_Processors_::When_Ambiguous_Matching_Actions.
          new( @token, self ).execute
      end

      # ~ interface for agents

    public
      attr_reader :stderr

      def expression_agent
        @expr_ag ||= bld_expression_agent
      end
    private
      def bld_expression_agent
        CLI::Expression_Agent__.new
      end

    public

      def usage_line
        client = self
        expression_agent.calculate do
          "#{ hdr "usage" } #{ client.invocation_string } #{ par 'action' } [..]"
        end
      end

      def invite_to_general_help_line
        client = self
        expression_agent.calculate do
          "use #{ code "#{ client.invocation_string } -h" } for help"
        end
      end

      def invocation_string
        @invocation_str_a * SPACE__
      end

      SPACE__ = ' '.freeze

      def name
        @name ||= Callback_::Name.from_variegated_symbol(
          @invocation_str_a.last.intern )
      end

      # ~ deep API for agents

      def get_visible_action_scanner
        get_action_scanner
      end

      def get_action_scanner
        Brazen_::Scanner_::Wrapper.new krnl.get_action_scanner do |action|
          Action__.new action, self
        end
      end

      class Action__
        def initialize action, kernel
          @action = action ; @kernel = kernel
        end

        def name
          @action.name
        end

        def one_line_description
          @action.get_one_line_description @kernel.expression_agent
        end
      end

    private
      def krnl
        @kernel ||= Brazen_::Kernel_.new( Brazen_, @invocation_str_a.last )
      end
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

      def par string  # make the string look like a parameter (placeholder)
        highlight "<#{ string }>"
      end

      def stylize style_d_a, string
        "\e[#{ style_d_a.map( & :to_s ).join( ';' ) }m#{ string }\e[0m"
      end
    end

    GENERIC_ERROR_ = 5
  end
end
