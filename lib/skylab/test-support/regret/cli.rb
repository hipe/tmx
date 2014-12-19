module Skylab::TestSupport

  module Regret::CLI

    def self.new * x_a
      Client.new( * x_a )
    end

    Client = ::Class.new TestSupport_._lib.CLI_client_base_class  # loads 'LIB_'
    RegretLib_ = Regret::API::RegretLib_
  end

  class Regret::CLI::Client

    API = Regret::API
    CLI = Regret::CLI
    RegretLib_ = API::RegretLib_

    API::Conf::Verbosity[ self ]

    def initialize( * )
      super
      @param_h = { }
      @pth = RegretLib_::Pretty_path_proc[]
      nil
    end

    use :hi, [ :last_hot, :as, :command ]

    # ~ hack an adapter for doc-test for this ancient [fa] legacy API

    namespace :doc_test, -> do
      Doc_Test_____
    end

    module Doc_Test_____
      module Adapter
        module For
          class Face

            module Of
              Hot = -> _NS_sheet, _doc_test_adpter_module do
                -> k, slug do
                  Adapter_____.new k, slug, _NS_sheet
                end
              end
            end

            def initialize kernel, slug, ns_sheet

              svcs = kernel.instance_variable_get :@parent_services  # meh
              a = svcs.three_streams
              a.push [ svcs.program_name, slug ]

              @ns_sheet = ns_sheet
              @native_client = TestSupport_::DocTest::CLI.new( * a )

            end

            def is_visible
              true
            end

            def name
              @ns_sheet.name
            end

            def get_summary_a_from_sheet ns_sheet
              @native_client.get_styled_description_string_array_via_name ns_sheet.name
            end

            def pre_execute
              true
            end

            def invokee
              @native_client
            end

            Adapter_____ = self
          end
        end
      end
    end

    # ~

  public

    option_parser do |o|
      o.separator "#{ NEWLINE_ }#{ hi 'description:' } make intermediate test files."
      o.separator "always safe to run - never clobbers.#{ NEWLINE_ }#{ NEWLINE_ }"
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

    LIB_.heavy_plugin_lib::Host::Proxy.enhance self do  # at end
      services [ :out, :ivar ],
               [ :err, :ivar ],
               [ :pth, :ivar ],
               [ :invitation ]
    end
  end
end
