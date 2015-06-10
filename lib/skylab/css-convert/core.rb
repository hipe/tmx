require_relative '..'
require 'skylab/callback/core'
require 'skylab/headless/core'

module Skylab::CSS_Convert

  class << self

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Brazen = sidesys[ :Brazen ]

    CLI_lib = -> do
      HL___[]::CLI
    end

    HL___ = sidesys[ :Headless ]

    Path_tools = -> do
      System[].filesystem.path_tools
    end

    System = -> do
      System_lib___[].services
    end

    System_lib___ = sidesys[ :System ]

    Treetop_tools = -> do
      TM__[]::Input_Adapters_::Treetop
    end

    TM__ = sidesys[ :TanMan ]
  end

  LIB_ = lib_

  Event_Sender_Methods_ = ::Module.new

  module Core
    # a namespace to hold modality-agnositc stuff
    module SubClient
      include Event_Sender_Methods_
    end
  end

  Headless_ = ::Skylab::Headless

  module Core::SubClient::InstanceMethods

    include Headless_::SubClient::InstanceMethods

  private

    def escape_path x
      request_client.escape_path x
    end
  end

  class Core::Params < ::Hash

    Headless_::Parameter::Definer[ self ]

    param :directives_file, pathname: true, writer: true do
      desc 'A file with directives in it.' # (not used yet)
    end
    param :dump_css, boolean: true
    param :dump_css_and_exit, boolean: true
    param :dump_directives, boolean: true
    param :dump_directives_and_exit, boolean: true
    param :force_overwrite, boolean: true
    param :tmpdir_absolute, accessor: true,
      default: LIB_.system.defaults.dev_tmpdir_pathname.join( 'css-cnvrt' )
  end

  module Core::Client
    # even though there is only one modality for now, we put non-CLI
    # specific things here just for clarity
  end

  module Core::Client::InstanceMethods

    include Core::SubClient::InstanceMethods

    Headless_::Parameter[ self, :parameter_controller, :oldschool_parameter_error_structure_handler ]

    def receive_event ev
      scn = ev.to_stream_of_lines_rendered_under expression_agent
      ok = ev.ok || ev.ok.nil?
      while line = scn.gets  # usually one line
        if ok
          x = send_info_string line
        else
          x = send_error_string line
        end
      end
      x
    end

  private

    def version
      send_payload_message "#{ program_name } #{ CSSC_::VERSION }"
      SUCCEEDED_
    end
  end

  module CLI
    def self.new sin, sout, serr
      CLI::Client.new sin, sout, serr
    end
  end

  class CLI::Client

    Headless_::CLI::Client[ self ]

    include Core::Client::InstanceMethods

    def initialize sin, sout, serr
      @default_action_i = nil
      @IO_adapter = build_IO_adapter sin, sout, serr
      super( )
    end

    def invoke( * )
      r = super
      GENERIC_ERROR_EXITSTATUS__ == r and usage_and_invite
      r
    end
  private
    def exitstatus_for_i i
      :ok == i ? GENERIC_OK_EXITSTATUS__ : GENERIC_ERROR_EXITSTATUS__
    end
    GENERIC_OK_EXITSTATUS__ = 0 ; GENERIC_ERROR_EXITSTATUS__ = -1
  public

    def convert directives_file
      result = :error
      begin
        set! or break
        p = CSSC_::Directive__::Parser.new self
        d = p.parse_stream( io_adapter.instream ) or break
        if ! dump_directives d
          result = :ok
          break
        end
        r = CSSC_::Directive__::Runner.new self
        r.invoke d or break
        result = :ok
      end while false
      if :error == result
        send_help_message usage_line
        send_help_message invite_line
      end
      exitstatus_for_i result
    end

    def actual_parameters
      @actual_parameters ||= formal_parameters_class.new
    end

    def expression_agent
      @IO_adapter.pen
    end

  private

    def resolve_IO_adapter_instream
      common_resolve_IO_adapter_instream
    end

    def build_option_parser
      require 'optparse'
      o = ::OptionParser.new

      o.base.long[ 'ping' ] = ::OptionParser::Switch::NoArgument.new do |_|
        enqueue_without_initial_queue :ping ; nil
      end

      o.on('-f', '--force', 'overwrite existing generated grammars') do
        actual_parameters.force_overwrite!
      end
      o.on('-d', '--dump={d|c}',
        '(debugging) Show sexp of directives (d) or css (c).',
        'More than once will supress normal output (e.g. "-dd -dd").') do |v|
        enqueue -> { dump_this v }
      end
      o.on('-t', '--test[=name]', 'list available visual tests. (devel)') do |v|
        enqueue( v ? -> { test v } : :test )
      end
      o.on('-h', '--help', 'this screen') { enqueue :help } # hehe comment out
      o.on('-v', '--version', 'show version') { enqueue :version }
      o
    end

    def ping
      @IO_adapter.errstream.puts "hello from css-convert."
      :'hello_from_css-convert'
    end

    def noop
      @noop_result
    end

    def default_action_i
      @default_action_i || :convert
    end

    DUMPABLE = {
      'directives' => -> {
        p.dump_directives? ? p.dump_directives_and_exit! : p.dump_directives!
      },
      'css' => -> { p.dump_css? ? p.dump_css_and_exit! : p.dump_css!  }
    }

    def dump_this str
      res = nil
      begin
        re = /\A#{ ::Regexp.escape str }/
        found = DUMPABLE.keys.detect { |s| re =~ s }  # :~+[#ba-015]
        if ! found
          usage_and_invite "need one of (#{
            }#{ DUMPABLE.keys.map(&:inspect).join ', ' }) #{
            }not: #{ str.inspect }"
          res = nil
          break
        end
        instance_exec(& DUMPABLE[found])
        equeue!( :convert ) unless :convert == queue.last # etc
        res = true
      end while nil
      res
    end

    def dump_directives sexp
      keep_going = true
      if actual_parameters.dump_directives?
        require 'pp'     # possible future fun with [#tm-043] svc # #todo
        ::PP.pp sexp, request_client.io_adapter.errstream
        keep_going = ! actual_parameters.dump_directives_and_exit?
      end
      keep_going
    end

    define_method :escape_path, LIB_.path_tools.pretty_path

    def formal_parameters_class
      Core::Params
    end

    def build_pen
      CLI::Pen.new method( :escape_path )
    end

  public

    def receive_event_on_channel__ ev, i
      x = nil
      ev.render_each_line_under expression_agent do | s |
        x = call_digraph_listeners i, s
      end
      x
    end
  end

  CLI::IO = ::Module.new

  class CLI::Pen

    include LIB_.CLI_lib.pen.instance_methods_module

    def initialize escape_path_p
      @p = escape_path_p
    end

    def em s
      stylize s, :strong, :cyan
    end

    def kbd s
      stylize s, :cyan
    end

    def pth x
      @p[ x ]
    end

    def indefinite_noun s  # meh for now
      if STARTS_WITH_VOWEL_RX__ =~ s
        "an #{ s }"
      else
        "a #{ s }"
      end
    end

    STARTS_WITH_VOWEL_RX__ = /\A[aeiouy]/i

    define_method :stylize, LIB_.brazen::CLI::Styling::Stylize
  end

  CLI::VisualTest = ::Module.new

  module CLI::VisualTest::InstanceMethods
  private
    def color_test _

      styling = CSSC_.lib_.brazen::CLI::Styling
      width = 50

      code_names = LIB_.brazen::CLI::Styling.code_name_symbol_array

      ( code_names - [ :strong ] ).each do |c|
        [[c], [:strong, c]].each do |a|

          _style_label = a.map( & :to_s ).join SPACE_

          s = "would you like some " <<
            "#{ styling.stylize _style_label, *a } with that?"

          u = styling.unstyle s

          fill = SPACE_ * [ width - u.length, 0 ].max
          send_payload_message "#{ fill }#{ s } - #{ u }"
        end
      end
      SUCCEEDED_
    end

    def fixture test
      require 'fileutils' # #[ta-042] as service  # #todo
      _pwd = ::Pathname.pwd
      _basename = "#{test.name}-#{test.value}"
      fixture_path = FIXTURES_DIR.join(_basename).relative_path_from(_pwd)
      _try = "#{program_name} #{fixture_path}"
      _msg = expression_agent.calculate do
        "#{ em 'try running this:' } #{ _try }"
      end
      send_info_message _msg
    end

    def test name=nil
      if name
        r = /\A#{::Regexp.escape(name)}/
        list = VISUAL_TESTS_[].select { |t| r.match t.name }  # :+[#ba-015]
      end
      if ! name or list.length > 1
        send_list_of_tests list || VISUAL_TESTS_[]
      elsif list.empty?
        send_error_message "no such test #{ name.inspect }"
        send_info_message invite_line
      else
        test = list.first
        send test.method, test
      end
    end

    def send_list_of_tests a
      fmt = '  %16s  -  %s'
      a.each do |o|
        send_payload_message fmt % o.values_at( 0..1 )
      end ; nil
    end
  end

  class CLI::Client
    include CLI::VisualTest::InstanceMethods
  end

  module Event_Sender_Methods_
  private

    def send_info_message s
      send_string_on_channel s, :info
    end

    def send_payload_message s
      send_string_on_channel s, :payload
    end

    def send_error_message s
      send_string_on_channel s, :error
    end

    def send_help_method s
      send_string_on_channel s, :help
    end
  end

  VISUAL_TESTS_ = Callback_.memoize do
    o = []
    o.push test.new( 'color test', 'see what the CLI colors look like.', :color_test )
    o.push test.new( '001', 'platonic-ideal.txt', :fixture )
    o.push tst.new( '002', 'minitessimal.txt', :fixture )
    o
  end

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  CSSC_ = self
  FIXTURES_DIR = CSSC_.dir_pathname.join 'test/fixtures'
  SPACE_ = ' '.freeze
  SUCCEEDED_ = true
  UNABLE_ = false

end
