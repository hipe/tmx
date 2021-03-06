module Skylab::TestSupport::TestSupport

  module Quickie

    def self.[] tcc
      tcc.include self
    end

    # -

      define_singleton_method :_dangerous_memoize, Home_::DANGEROUS_MEMOIZE

      # -- context-level testing (targeting CLI client)

      def want_finished_line_ o
        o.want %r(\A\nFinished in \d+(?:\.\d+)?(?:e-\d+)? seconds?\z)
      end

      def run_the_tests_thru_a_CLI_expecting_everything_on_STDOUT_ & p
        _run_the_tests_thu_a_CLI_expecting true, p
      end

      def run_the_tests_thru_a_CLI_expecting_everything_on_STDERR_ & p
        _run_the_tests_thu_a_CLI_expecting false, p
      end

      def _run_the_tests_thu_a_CLI_expecting sout_not_serr, p

        args = TheseArgs___.define( & p )

        _lib = Zerk_test_support_[]::Non_Interactive_CLI::Fail_Early

        sess = _lib::SingleStreamExpectations.define do |o|
          args.want_lines_by[ o ]  # hi.
        end.to_assertion_session_under self

        if sout_not_serr
          @STDERR = :_not_expecting_stderr_TS_
          @STDOUT = sess.downstream_IO_proxy
        else
          @STDERR = sess.downstream_IO_proxy
          @STDOUT = :_not_expecting_stdout_TS_
        end

        rt = build_runtime_

        _svc = _start_quickie_service_expecting_CLI sout_not_serr, rt

        _mod = enhanced_module_via_runtime_ rt
        x = args.receive_test_support_module_by[ _mod ]  # runs the tests
        sess.finish
        x
      end

      class TheseArgs___ < Common_::SimpleModel
        attr_accessor(
          :want_lines_by,
          :receive_test_support_module_by,
        )
      end

      def enhanced_module_via_runtime_ rt
        mod = Sandbox_moduler___[]
        rt.__enhance_test_support_module_with_the_method_called_describe mod
        mod
      end

      # -- example-level testing

      def given_this_context_ & p
        @CONTEXT_BODY = p
      end

      def given_this_example_ & p
        @EXAMPLE_BODY = p
      end

      def want_example_passes_with_message_ s
        exe = _execute_the_example
        :pass == exe.category_symbol or fail "expected pass, had fail"
        exe.message == s or fail _say_bad_message( exe, s )
      end

      def want_example_fails_with_message_ s
        exe = _execute_the_example
        :fail == exe.category_symbol or fail "expected fail, had pass"
        exe.message == s or fail _say_bad_message( exe, s )
      end

      def _say_bad_message exe, s
        "for predicate message, expected #{ s.inspect }, had #{ exe.message.inspect }"
      end

      def run_the_context_
        ContextExecutionState_via_ContextBody___.call(
          remove_instance_variable :@CONTEXT_BODY )
      end

      def _execute_the_example
        _p = remove_instance_variable :@EXAMPLE_BODY
        ExampleExecutionState_via_ExampleBody___[ _p ]
      end

      def want_example_ s_a  # for API calls
        want :data, :example do |eg|
          if eg.description_stack != s_a
            fail
          end
        end
      end

      # --

      def want_API_result_for_fail_
        want_result NIL
      end

      # --

      def build_runtime_
        subject_module_::Runtime___.define do |o|
          o.kernel_module = kernel_module_
          o.toplevel_module = toplevel_module_
        end
      end

      def start_quickie_service_expecting_CLI_output_all_on_STDERR_ rt
        _start_quickie_service_expecting_CLI false, rt
      end

      def start_quickie_service_expecting_CLI_output_all_on_STDOUT_ rt
        _start_quickie_service_expecting_CLI true, rt
      end

      def _start_quickie_service_expecting_CLI sout_not_serr, rt

        if sout_not_serr
          serr = :_not_expecting_stderr_TS_
          sout = stdout_
        else
          serr = stderr_
          sout = :_not_expecting_stdout_TS_
        end

        _argv = self.ARGV_

        _svc = rt.start_quickie_service_ _argv, :_no_see_ts_, sout, serr, PNSA___
        _svc  # hi. #todo
      end

      PNSA___ = %w( sperk.kd )

      def ARGV_
        remove_instance_variable :@ARGV
      end

      def stderr_
        remove_instance_variable :@STDERR
      end

      def stdout_
        remove_instance_variable :@STDOUT
      end

      _dangerous_memoize :kernel_module_with_rspec_not_loaded_ do
        Home_::MockModule.define do |o|
          o.have_method_not_defined :should
          o.want_to_have_method_defined :should
        end
      end

      _dangerous_memoize :toplevel_module_with_rspec_not_loaded_ do
        Home_::MockModule.define do |o|
          o.have_const_not_defined :RSpec
        end
      end

      _dangerous_memoize :toplevel_module_with_rspec_already_loaded_ do
        Home_::MockModule.define do |o|
          o.have_const_defined :RSpec
        end
      end

      def hack_runtime_to_build_this_service_ rt, & p
        seen = false  # redundant with a test above but meh
        rt.send :define_singleton_method, :__start_quickie_service_autonomously do
          seen && fail
          seen = true
          svc = p[]
          send @_write_quickie_service, svc
          svc
        end
      end

      def subject_CLI
        ProxyForQuickieOnefilePretendingToBe_CLI_Class___.new self
      end

      def subject_API
        ProxyForQuickieOnefilePretendingToBe_API_Module___.new self
      end

      def prepare_subject_CLI_invocation _
        NIL  # hi.
      end

      def begin_mock_module_
        Home_::MockModule.new
      end

      def subject_module_
        Subject_module__[]
      end
    # -

    # ==

    ContextExecutionState_via_ContextBody___ = -> p do
      # -
        lib = Subject_module__[]
        tcc = New_context_class___[]

        lib::Initialize_context_class__[ tcc, p, [ "_no_see_ts_" ] ]

        rec = MoreRealisticRecordingClient___.new
        stats = lib::StatisticsAggregator___.new rec

        lib::RunTests_via_TestContextClass_and_Client__.define do |o|
          o.client = rec
          o.statistics_aggregator = stats
          o.test_context_class = tcc
        end.execute

        _frozen_client = rec.flush_via_result stats
        _frozen_client  # hi.
      # -
    end

    # ==

    hack_thing_once = -> do
      hack_thing_once = nil
      Home_::Quickie::Context__.send :alias_method, :expect_, :expect

      # this gives us an extra added assurance that even when we are running
      # our tests using r.s, we are using the quickie version of `expect`
      # and not r.s's.

    end

    ExampleExecutionState_via_ExampleBody___ = -> p do
      # -
        rec = SingleExampleSingleAssertionRecordingClient___.new
        lib = Subject_module__[]
        stats = lib::StatisticsAggregator___.new rec
        _ctx = lib::Context__.new stats

        hack_thing_once && hack_thing_once[]

        _result = _ctx.instance_exec( & p )
        rec.flush_via_result _result
      # -
    end

    # ==

    class ProxyForQuickieOnefilePretendingToBe_CLI_Class___

      # we pretend that our quickie service is "long-running", *and*
      # it starts *around* a client (probably CLI), so it does not exit
      # per se.. not yet..
      #
      # but anyway here we pretend like the service "exits" with exitstatus
      # integers just so it can play nice with our ever-useful [ze] niCLI
      # fail-early test library..

      def initialize c
        @__context = c
      end

      def new * five
        @__EEK = five
        self
      end

      def execute
        argv, sin, sout, serr, pn_s_a = remove_instance_variable :@__EEK
        _rt = @__context.build_runtime_
        svc = _rt.start_quickie_service_ argv, sin, sout, serr, pn_s_a
        # (hack it so it results in exitstatuses so we can use the etc)
        if svc
          self._CONFIRM_THAT_IT_IS_THE_SERVICE
          0
        elsif false == svc
          113  # any nonzero exitstatus ('q'.ord)
        else
          0  # assume help
        end
      end
    end

    # ==

    class ProxyForQuickieOnefilePretendingToBe_API_Module___

      def initialize c
        @__context = c
      end

      def invocation_via_argument_array x_a, & p
        @__arguments_array = x_a ; @__listener = p
        self
      end

      def execute
        x_a = remove_instance_variable :@__arguments_array
        p = remove_instance_variable :@__listener
        _runtime = @__context.build_runtime_
        _ = _runtime.receive_API_call_ p, x_a
        _  # #todo
      end
    end

    # ==

    class MoreRealisticRecordingClient___

      def initialize
        @_seen_FOR_TEST_ = []
      end

      def begin_branch_node d, tcc
        @_seen_FOR_TEST_.push [ d, tcc.description ]
      end

      def begin_leaf_node d, eg
        @_seen_FOR_TEST_.push [ d, eg.description ]
      end

      def flush
        NOTHING_
      end

      def flush_via_result stats
        stats.close
        @_stats_FOR_TEST_ = stats
        @_seen_FOR_TEST_.freeze
        freeze
      end

      def _choices_
        NOTHING_
      end

      attr_reader( :_seen_FOR_TEST_, :_stats_FOR_TEST_ )
    end

    # ==

    class SingleExampleSingleAssertionRecordingClient___

      def initialize
        @_receive_category_symbol = :__receive_category_symbol_initially
      end

      def receive_failure msg_p, failed_count
        send @_receive_category_symbol, :fail
        _receive_message msg_p
        NIL  # like the production collaborator
      end

      def receive_pass msg_p
        send @_receive_category_symbol, :pass
        _receive_message msg_p
        NIL  # ibid
      end

      def _receive_message msg_p
        @message = msg_p.call  # call it with its original context
        NIL
      end

      def __receive_category_symbol_initially sym
        @category_symbol = sym
        @_receive_category_symbol = :_CLOSED ; nil
      end

      def flush_via_result x
        remove_instance_variable :@_receive_category_symbol
        @result = x
        freeze
      end

      attr_reader(
        :category_symbol,
        :message,
      )
    end

    # ==

    Subject_module__ = Lazy_.call do
      Home_::Quickie
    end

    # ==

    Sandbox_moduler___ = -> do  # a bespoke #[#ts-048], here for independence
      box_mod = nil ; last_d = nil
      main = -> do
        mod = ::Module.new
        box_mod.const_set "Module#{ last_d += 1 }", mod
        mod
      end
      p = -> do
        last_d = -1
        box_mod = module SandboxModules___
          self
        end
        ( p = main )[]
      end
      -> do
        p[]
      end
    end.call

    # ==

    -> do
      d = 0
      New_context_class___ = -> do
        cls = ::Class.new Subject_module__[]::Context__
        TS_.const_set "Context#{ d += 1 }", cls
        cls
      end
    end.call

    # ==
    # ==
  end
end
# #born years later
