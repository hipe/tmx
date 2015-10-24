require 'skylab/callback'

module Skylab::CSS_Convert

  class << self

    def describe_into_under y, _
      y << "(ancient thing that drove the development of [hl])"
    end

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]

    # Brazen = sidesys[ :Brazen ]  # stay here for [sl]

    Fields = sidesys[ :Fields ]

    Flex_to_treetop = sidesys[ :Flex2Treetop ]

    My_sufficiently_existent_tmpdir = Callback_.memoize do

      dirname = Home_.lib_.system.defaults.dev_tmpdir_path
      if ! ::File.exist? dirname
        ::Dir.mkdir dirname
      end

      path = ::File.join dirname, '[cc]'
      if ! ::File.exist? path
        ::Dir.mkdir path
      end
      path
    end

    Path_tools = -> do
      System[].filesystem.path_tools
    end

    System = -> do
      System_lib[].services
    end

    System_lib = sidesys[ :System ]

    Treetop_tools = -> do
      TM__[]::Input_Adapters_::Treetop
    end

    TM__ = sidesys[ :TanMan ]

    Yacc_to_treetop = sidesys[ :Yacc2Treetop ]
  end

  Brazen_ = Autoloader_.require_sidesystem :Brazen
  Home_ = self

  Param_Lib_ = Home_.lib_.fields::Parameter

  class Conversion_Parameters___ < ::Hash

    Param_Lib_::Definer[ self ]

    meta_param :required, :boolean

    param :directives_file, :writer do
      desc 'A file with directives in it.'  # (not used yet)
    end

    param :dump_CSS, :boolean

    param :dump_directives, :boolean

    param :dump_then_finish, :boolean

    param :force_overwrite, :boolean

    param :tmpdir_absolute, :accessor do

      default do
        Home_.lib_.my_sufficiently_existent_tmpdir
      end
    end

    # ~ because parameter controller
    #   (we are torn as to whether this or a proper client should be it)

    define_method :normalize, Param_Lib_::Controller::NORMALIZE_METHOD

    def initialize & oes_p
      @on_event_selectively = oes_p
    end
  end

  class CLI < Brazen_::CLI::Isomorphic_Methods_Client

    option_parser do | o |

      o.base.long[ 'ping' ] = ::OptionParser::Switch::NoArgument.new do |_|

        __clear_and_enqueue :__ping
      end

      o.on('-f', '--force', 'overwrite existing generated grammars') do

        actual_parameters.force_overwrite!
      end

      o.on('-d', '--dump={d|c}',
        '(debugging) Show sexp of directives (d) or css (c).',
        'More than once will supress normal output (e.g. "-dc -dc").') do |v|

        enqueue do
          __dump_this v
        end
      end

      o.on('-t', '--test[=name]', 'list available visual tests. (devel)') do |v|

        enqueue v ? -> { _test v } : :_test
      end

      o.on('-h', '--help', 'this screen') { enqueue :help } # hehe comment out

      o.on('-v', '--version', 'show version') { enqueue :version }

      o
    end

    def convert directives_file

      @_directives_path = directives_file

      ok = actual_parameters.normalize
      ok &&= __resolve_directives
      ok &&= __via_directives
      ok || @_result
    end

    def any_exit_status_for_channel_symbol sym  # covered
      if :errno_enoent == sym
        super :resource_not_found
      else
        super sym
      end
    end
  end

  class CLI::Modalities::CLI::Actions::Convert

    # here's the nasty hacking we have to do to circumvent normal processing:
    # the method(s) below need to be overridden in the child action class,
    # not the "user utility" class.

    def bound_call_from_parse_options
      bc = super
      if bc
        bc  # if the o.p failed to parse options normal-style, exit.
      else

        q = @parent._queue_
        if q  # if there is a queue, assume assume some non-normal processing

          d = q.flush_until_nonzero_exitstatus

          if d.zero?  # if everthing went well, typically we want to exit..
            o = @parent
            if o._can_exit && ! o._must_stay

              es = o.exitstatus
              es ||= Brazen_::CLI::SUCCESS_EXITSTATUS
              Callback_::Bound_Call.via_value es
            else
              NIL_  # keep going if something said must stay
            end
          else
            express_invite_to_general_help
            Callback_::Bound_Call.via_value d
          end
        else  # if no queue keep going
          NIL_
        end
      end
    end
  end

  module Transitional___

    attr_reader(
      :_can_exit,
      :exitstatus,  # [tmx] - to let our action child read it
      :_must_stay,
    )

    def initialize( * )

      @_can_exit = false
      @_must_stay = false

      handle_event_selectively

      oes_p = @on_event_selectively
      @on_event_selectively = -> * i_a, & ev_p do

        oes_p[ * i_a, & ev_p ]
      end

      super
    end

    # ~ business

    def __ping

      @_can_exit = true
      @resources.serr.puts "hello from css convert."
      @exitstatus = :'hello_from_css_convert'
      CLI::SUCCESS_EXITSTATUS
    end

    def version

      @_can_exit = true
      _ = ::File.basename @resources.invocation_string_array.last
      @resources.sout.puts "#{ _ } #{ Home_::VERSION }"
      @exitstatus ||= CLI::SUCCESS_EXITSTATUS  # result
      CLI::SUCCESS_EXITSTATUS
    end

    def _test x=nil

      @_can_exit = true
      CLI_Visual_Test___.new( self ).test x
    end

    # ~

    def __dump_this letter

      @_must_stay = true

      @_DUMPABLES = [ 'CSS', 'directives' ]

      s_a = Home_.lib_.basic::Fuzzy.reduce_array_against_string(
        @_DUMPABLES,
        letter,
      )

      case 1 <=> s_a.length
      when 1
        __when_not_dumpable letter
      when 0
        send :"__dump__#{ s_a.fetch 0 }__"
      end
    end

    def __dump__CSS__

      o = actual_parameters
      if o.dump_CSS?
        o.dump_then_finish!
      else
        o.dump_CSS!
      end
      CLI::SUCCESS_EXITSTATUS
    end

    def __dump__directives__

      o = actual_parameters
      if o.dump_directives?
        o.dump_then_finish!
      else
        o.dump_directives!
      end
      CLI::SUCCESS_EXITSTATUS
    end

    def __when_not_dumpable letter

      @resources.serr.puts "need one of (#{

      }#{ @_DUMPABLES.map( & :inspect ).join ', ' }) #{
          }not: #{ letter.inspect }"

      CLI::GENERIC_ERROR_EXITSTATUS
    end

    def __resolve_directives

      _out_dir_base = @_parameters.fetch :tmpdir_absolute

      _directive_parser = Home_::Directive__::Parser.new(
        _out_dir_base,
        @resources,
        & @on_event_selectively )

      dirx = _directive_parser.parse_path @_directives_path
      if dirx
        @_directives = dirx
        __when_directives
      else
        @_result = dirx
        UNABLE_
      end
    end

    def __when_directives

      px = @_parameters
      if px.dump_directives?
        require 'pp'     # possible future fun with [#tm-043] svc # #todo
        ::PP.pp sexp, request_client.io_adapter.errstream
        if px.dump_then_finish?
          @_result = CLI::SUCCESS_EXITSTATUS
          EARLY_FINISH_
        else
          ACHIEVED_
        end
      else
        ACHIEVED_
      end
    end

    def __via_directives

      _dr = Home_::Directive__::Runner.new self
      _ok = _dr.invoke @_directives
      self._HELLO
    end

    # ~ params (boilerplate adaptation, legacy names)

    def actual_parameters
      @_parameters ||= __build_parameters
    end

    def __build_parameters
      Conversion_Parameters___.new( & @on_event_selectively )
    end

    # ~ queue (somewhat boilerplate adaptation to agent)

    def __clear_and_enqueue  * a, & p
      _queue.clear
      _enqueue a, & p
    end

    def enqueue * a, & p
      if p
        a.length.zero? or raise ::ArgumentError
        _enqueue nil, & p
      elsif 1 == a.length && a.first.respond_to?( :call )
        _enqueue nil, & a.first
      else
        _enqueue a
      end
    end

    def _enqueue a, & p
      if p
        _queue.accept_by( & p )
      else
        _queue.accept_method_call a[ 1..-1 ], a.fetch( 0 )
      end
      NIL_
    end

    attr_reader(
      :_queue_,
    )

    def _queue
      @_queue_ ||= Home_.lib_.basic::Queue.build_for self
    end

    # ~ services for clients

    def program_name
      @resources.invocation_string_array.join SPACE_
    end

    def receive_event_on_channel__ ev, sym

      ev.render_each_line_under expression_agent do | line |

        @resources.serr.puts line
      end
      NIL_
    end
  end

  CLI.include Transitional___

  class CLI::Expression_Agent < Brazen_::CLI::Expression_Agent

    # (this is a pedagogic example of taking the default expag from the
    # distribution and customizing it with in this case a specific color)

    def em s
      stylize s, :strong, :cyan
    end

    def kbd s
      stylize s, :cyan
    end

    def ick x
      %|"#{ x }"|
    end

    def par x
      _slug = if x.respond_to? :name
        x.name.as_slug
      else
        x.id2name.gsub UNDERSCORE_, DASH_
      end
      kbd "<#{ _slug }>"
    end

    def indefinite_noun s  # meh for now. #todo
      if STARTS_WITH_VOWEL_RX__ =~ s
        "an #{ s }"
      else
        "a #{ s }"
      end
    end

    STARTS_WITH_VOWEL_RX__ = /\A[aeiouy]/i

    define_method :stylize, Brazen_::CLI::Styling::Stylize
  end

  # ~ visual tests, etc

  Visual_tests__ = Callback_.memoize do

    Test___ = ::Struct.new :name_s, :desc_s, :method_name
    a = []
    o = -> s, s_, i do
      a.push Test___.new( s, s_, i )
    end
    o[ 'color test', 'see what the CLI colors look like.', :color_test ]
    o[ '001', 'platonic-ideal.txt', :fixture ]
    o[ '002', 'minitessimal.txt', :fixture ]
    a
  end

  class CLI_Visual_Test___

    def initialize client

      @_client = client
    end

    # ~ "business"

    def color_test _test_o

      modifiers_a = [ nil, :strong, :reverse ]
      styling = Brazen_::CLI::Styling
      stylify = styling::Stylify
      width = 50

      _code_names = Brazen_::CLI::Styling.code_name_symbol_array
      _code_names.each do | c |

        3.times do | d |

          a = if d.zero?
            [ c ]
          else
            [ modifiers_a.fetch( d ), c ]
          end

          _style_label = a.map( & :to_s ).join SPACE_

          s = "would you like some " <<
            "#{ stylify[ a, _style_label ] } with that?"

          u = styling.unstyle s

          fill = SPACE_ * [ width - u.length, 0 ].max
          send_payload_message "#{ fill }#{ s } - #{ u }"
        end
      end

      CLI::SUCCESS_EXITSTATUS
    end

    def fixture test_o

      _basename = "#{ test_o.name_s }-#{ test_o.desc_s }"

      path = ::File.join FIXTURES_DIR__, _basename

      pwd = ::Dir.pwd
      d = pwd.length
      if pwd == path[ 0, d ] && ::File::SEPARATOR == path[ d ]
        path = path[ ( d + 1 ) .. -1 ]
      end

      c = @_client

      _try = "#{ c.program_name } convert #{ path }"  # while #open [#002]

      _msg = c.expression_agent.calculate do
        "#{ em 'try running this:' } #{ _try }"
      end

      send_info_message _msg

      CLI::SUCCESS_EXITSTATUS
    end

    # ~ "not business"

    def test name=nil

      if name

        list = Home_.lib_.basic::Fuzzy.reduce_array_against_string(
          Visual_tests__[],
          name
        ) do | o |
          o.name_s
        end
      end

      if ! name or list.length > 1
        send_list_of_tests list || Visual_tests__[]
      elsif list.empty?
        send_error_message "no such test #{ name.inspect }"
        CLI::GENERIC_ERROR_EXITSTATUS
      else
        test = list.first
        send test.method_name, test
      end
    end

    def send_list_of_tests a
      fmt = '  %16s  -  %s'
      a.each do |o|
        send_payload_message fmt % o.values_at( 0..1 )
      end
      CLI::SUCCESS_EXITSTATUS
    end

    # ~ experimental legacy adaptation

    def _same s
      @_client.resources.serr.puts s
    end

    alias_method :send_error_message, :_same
    alias_method :send_info_message, :_same

    def send_payload_message s
      @_client.resources.sout.puts s
    end
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  EARLY_FINISH_ = nil
  FIXTURES_DIR__ = ::File.join Home_.dir_pathname.to_path, 'test/fixtures'
  NIL_ = nil
  SPACE_ = ' '.freeze
  UNABLE_ = false

end
