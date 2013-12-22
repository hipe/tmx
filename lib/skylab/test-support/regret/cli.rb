module Skylab::TestSupport::Regret::CLI

  API = ::Skylab::TestSupport::Regret::API
  Face = ::Skylab::Face
  CLI = self

  def self.new *a
    CLI::Client.new( * a )
  end

  class CLI::Client < Face::CLI

    API::Conf::Verbosity[ self ]

    def initialize( * )
      super
      @param_h = { }
      @pth = Face::Services::Headless::CLI::PathTools::FUN.pretty_path
      nil
    end

    use :hi, [ :last_hot, :as, :command ]

    option_parser do |o|

      o.separator "#{ hi 'description:' } process <path> with doc-test. #{
        }results to stdout by default."

      o.separator "#{ hi 'options:' }"

      pr = CLI::Actions::DocTest::Parse_Recursive_

      hack = o.define '-r', "--recursive",
        "regenerate all under path (directory) recursively.",
        "(assumes the existence of \"#{ API::Conf[:doc_test_dir] }\" #{
          }somewhere above)",
        "the (mutually exclusive) sub-options for this beast include:",
        * ( pr::A_.reduce( [] ) do |m, f|
          f.with_each_desc_line { |s| m << "  #{ s }" } ; m
        end ),
        "(various forms work: \"-rl\", \"-rn\", \"-r dry\")" do

        v = (( @param_h[:recursive_o] ||= pr::Value_.new ))
        pr[ @y, v, @argv ]

        @mechanics.change_command :recursive
        nil
      end
      hack.short[ 0 ] = "#{ hack.short.first } [ list | check | dry-run | -- ]"

      o.on '-F', '--force', "when used with -r, confirms file overwrite" do
        @param_h[:do_force] = true
      end

      ext = ::Skylab::Autoloader::EXTNAME
      core = API::DEFAULT_CORE_BASENAME_

      o.on '-c', "--core[=foo#{ ext }]",
        "try to load missing constants by first looking for a #{ core }",
        "(for e.g) file under a corresponding inferred directory" do |s|
        @param_h[ :core_basename ] = s || core
      end

      o.on '-t', '--template-option <x>',
          "template option (try \"-t help\")" do |x|
        ( @param_h[:template_option_a] ||= [ ] ) << x
      end

      o.on '-- <load-module>',
          "(distinguishes <load-module> from <load-file>)" do |x|
        @param_h[:load_module] = x
      end

      o.on '-v', '--verbose', 'verbose. (try multiple.)', & verbosity_opt_func
      o.on '-V', '--less-verbose', 'reduce verbosity.', &
        deincrement_verbosity_opt_func

      o.banner = command.usage_line
    end

    set :node, :doc_test,
      :render_argument_syntax_as,
        '<path> [ <load-file> ] [ -- <load-module> ]',
      :additional_help_proc, -> y do
        y << "#{ hi '    arguments:' }"
        y <<        "    <load-file> is a bootstrapping file to load before #{
          }your main is loaded"
        y <<        "    <load-module> e.g Foo::NLP::EN (because autoloading #{
          }doesn't always work)"
      end

    def doc_test *a
      if (( r = parse_doc_test_args a ))
        r = execute_with :param_x, @param_h
      end
      r
    end

  private

    def parse_doc_test_args a
      a.length.nonzero? and path = a.shift
      a.length.nonzero? and load_file = a.shift
      if a.length.nonzero?
        @y << "unexpected argument(s) - #{ a.fetch( 0 ).inspect }"
        false
      elsif ! path and ! @param_h[ :template_option_a ]  # eew
        @y << "wrong number of arguments (0 for 1..)"
        @y << "expecting <path>"
        false
      else
        @param_h[ :load_file ] = load_file
        @param_h[ :path ] = path
        true
      end
    end

  public

    set :node, :recursive, :invisible

    def recursive path=nil
      r = recursive_check_bad_keys &&
        recursive_dissolve_subcommand
      if r
        api( path )
      elsif false == r
        @mechanics.change_command :doc_test  # eew
        invite
      end
    end

  private

    def recursive_check_bad_keys
      if (( bad_a = @param_h.keys - WHITE_A__ )).length.nonzero?
        omg = Face::Services::Headless::NLP::EN.calculate do
          "the #{ and_ bad_a.map( & Cleanup_hack__ ) } option#{ s } #{
            }#{ s :is } not supported with the recursive option."
        end
        @y << omg
        false
      else true end
    end
    WHITE_A__ = %i( core_basename do_force recursive_o vtuple ).freeze
    Cleanup_hack__ = -> i do
      "'#{ Headless::Name::FUN::Labelize[ i ].downcase }'"
    end

    def recursive_dissolve_subcommand
      if (( o = @param_h.delete :recursive_o ))
        if o.did_error then false else
          @param_h[ :mode ] = o.to_i
        end
      else true end
    end

  public

    option_parser do |o|
      o.separator "\n#{ hi 'description:' } make intermediate test files."
      o.separator "always safe to run - never clobbers.\n\n"
      o.separator "#{ hi 'options:' }"

      @param_h[:do_preview] = nil
      o.on '-p', '--preview', 'writes file output to stderr' do
        @param_h[:do_preview] = true
      end

      o.on '--top <top>', "indicate a toplevel node, e.g \"skylab\".",
        "(only used when disambiguation is necessary)" do |v|
        @param_h[:top] = v
      end

      o.on '-v', '--verbose', 'verbose (try multiple.)', & verbosity_opt_func
      o.on '-V', '--less-verbose', 'reduce verbosity.', &
        deincrement_verbosity_opt_func

      o.on '-n', '--dry-run', 'dry-run.' do
        @param_h[:is_dry_run] = true
      end

      o.banner = command.usage_line
    end

    def intermediates path
      if path and SEP_ != path.getbyte( 0 )
        path = ::File.expand_path path
      end
      api path
    end
    SEP_ = '/'.getbyte 0

    set :node, :simplecov, :autonomous

    def simplecov * arg
      kls = CLI::Actions::Simplecov
      cli = kls.new @sin, @out, @err
      s_a = @mechanics.get_normal_invocation_string_parts << 'simplecov'
      cli.program_name = s_a * ' '
      # the client uses `load` to load the target file, hence it expects to
      # be passed the global `argv` so that it can parse it destructively
      # so that the target file gets only the arguments intended for it.
      # this is why we don't pass it `arg` above - `arg` is a deep copy
      # of argv (but it is decorative - it generates the syntax).
      argv = @mechanics.last_hot.release_argv
      argv == arg or fail "sanity"
      cli.invoke argv
    end

    set :node, :ping, :invisible

    def ping
      api
    end

  private
  dsl_off

    # implement services:

    def pth ; @pth end  # avoid `private attribute?` warning

    def invite x=nil, msg=nil
      msg and @y << msg
      @mechanics.invite_for @y, ( x || @mechanics.last_hot_recursive )
      nil
    end

    def api * method_param_a
      e = get_exe_with :param_x, method_param_a
      execute e
    end

    def execute_with * a
      e = get_exe_with( *a )
      execute e
    end

    def get_exe_with * a
      a.unshift( method( :get_expression_agent ) ).unshift :expression_agent_p
      @mechanics.get_api_executable_with( * a )
    end

    def get_expression_agent hot_api_action
      CLI::Expression_Agent_.new :hot_API_action, hot_api_action,
        :procs, [ :hi, method( :hi ) ]
    end

    def execute ex
      r = if ex
        ex.execute
      else ex end
      if false == r
        invite
        r = nil
      end
      r
    end

    Face::Services::Headless::Plugin::Host::Proxy.enhance self do  # at end
      services [ :out, :ivar ],
               [ :err, :ivar ],
               [ :pth, :ivar ],
               [ :invitation ]
    end
  end
end
