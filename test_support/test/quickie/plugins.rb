module Skylab::TestSupport::TestSupport

  module Quickie

    module Plugins

      def self.[] tcc
        tcc.include self
      end

      # (as an experiment, we're gonna try to make this hybrid of API & CLI
      #  support, so that you can run either from the same test node)

      # -

        def invoke * argv
          @API_OR_CLI = :CLI
          @CLI = CLI_lib___[]::Client_for_Expectations_of_Invocation.new
          @CLI.invoke_via_argv argv
          NIL
        end

        def call * x_a
          @API_OR_CLI = :API
          @API = Common_.test_support::Expect_Emission_Fail_Early::Spy.new
          @API.receive_call x_a
        end

        # ~

        def write_messages_into_for_no_transition_because_nothing_pending_ y
          y << "there are no pending executions"
          y << "so nothing brings the system from the beginning state to a finished state"
        end

        def expect_no_transition_found_ & p
          messages_from_expect_for_API_ :error, :expression, :no_transition_found, & p
        end

        def expect_these_lines_on_stderr_
          # experiment - not ideal because it confuses who's driving
          on_stream :serr
          _y = ::Enumerator::Yielder.new do |line|
            expect line
          end
          yield _y
          NIL
        end

        def messages_from_expect_for_API_ * chan, & p
          msgs = nil
          expect_for_API_ chan do |y|
            msgs = y
          end
          expect_fail
          if block_given?
            expect_these_lines_in_array_ msgs, & p
          else
            msgs
          end
        end

        def fails_with_these_messages_ & p
          expect_these_lines_in_array_ messages_, & p
        end

        # ~

        def expect_on_stderr s
          @CLI.expect_on_stderr s
        end

        def expect_on_stdout s
          @CLI.expect_on_stdout s
        end

        def on_stream sym
          @CLI.on_stream sym
        end

        def expect_styled_line * chunks
          @CLI.expect_styled_line_via chunks
        end

        def expect_each_by & p
          @CLI.expect_each_by( & p )
        end

        def expect *a, &p
          send EXPECT___.fetch( @API_OR_CLI ), a, & p
        end

        EXPECT___ = { API: :expect_for_API_, CLI: :__expect_for_CLI }

        def __expect_for_CLI a
          @CLI.expect( * a )
        end

        def expect_for_API_ a, & p
          @API.expect_emission p, a
        end

        # ~

        def expect_these_lines_in_array_ actual_messages

          act_line_scn = Common_::Scanner.via_array actual_messages

          _y = ::Enumerator::Yielder.new do |exp_line|

            if act_line_scn.no_unparsed_exists
              fail "had no more lines when expecting: #{ exp_line.inspect }"
            else
              act_line = act_line_scn.gets_one
              if exp_line.respond_to? :ascii_only?
                act_line == exp_line || fail
              else
                act_line =~ exp_line || fail
              end
            end
          end

          yield _y

          if ! act_line_scn.no_unparsed_exists
            fail "had unexpected extra line: #{ act_line_scn.head_as_is.inspect }"
          end
        end

        # ~

        def expect_fail_normally_
          cli = remove_instance_variable :@CLI
          cli.expect_on_stderr "try 'xx yy' for help"
          _nothing = cli.expect_fail_under self
          self._COVER_ME
          _nothing  # hi.
        end

        # ~

        def expect_fail
          send EXPECT_FAIL___.fetch @API_OR_CLI
        end

        EXPECT_FAIL___ = {
          API: :_expect_fail_for_API,
          CLI: :__expect_fail_for_CLI,
        }

        def __expect_fail_for_CLI
          @CLI.expect_fail_under self
        end

        def _expect_fail_for_API

          # failure results should now be nil not false to leave room
          # for meaningful false #coverpoint-2-2

          @API.expect_result_under NIL, self  # #here
        end

        # ~

        def expect_succeed
          send EXPECT_SUCCEED___.fetch @API_OR_CLI
        end

        EXPECT_SUCCEED___ = {
          API: :__expect_succeed_for_API,
          CLI: :__expect_succeed_for_CLI,
        }

        def __expect_succeed_for_CLI
          @CLI.expect_succeed_under self
        end

        def __expect_succeed_for_API
          # same as #here (succeed) becuase (see)
          @API.expect_result_under NIL, self
        end

        def expect_result x
          @API.expect_result_under x, self
        end

        def finish_by & p
          @API.receive_finish_by p, self
        end

        # ~

        def DEBUG_ALL_BY_FLUSH_AND_EXIT
          send DEBUG_etc___.fetch @API_OR_CLI
        end

        DEBUG_etc___ = { API: :__DEBUG_for_API, CLI: :__DEBUG_for_CLI }

        def __DEBUG_for_CLI
          @CLI.DEBUG_ALL_BY_FLUSH_AND_EXIT_UNDER self
        end

        def __DEBUG_for_API
          @API.DEBUG_ALL_BY_FLUSH_AND_EXIT_UNDER self
        end

        # --

        def use_fake_paths_ mock_key
          @THESE_FAKE_PATHS = yield []
          @MOCK_KEY = mock_key ; nil
        end

        def prepare_subject_API_invocation_for_fake_paths_ invo

          fake_paths = remove_instance_variable :@THESE_FAKE_PATHS
          mock_key = remove_instance_variable :@MOCK_KEY

          _msvc = invo.instance_variable_get :@__tree_runner_microservice
          _pi = _msvc.DEREFERENCE_PLUGIN :path
          _pi.send :define_singleton_method, :__to_test_file_path_stream do

            _s_a = remove_instance_variable :@_mixed_path_arguments  # implicit assertion of once
            _s_a == [ mock_key ] || TS_._SANITY
            Home_::Stream_[ fake_paths ]
          end

          invo
        end

        # --

        def hack_that_one_plugin_of_invocation_to_use_this_runtime_ invo, & p

          # touch the particular plugin "early" and hack this one method on it

          _msvc = invo.instance_variable_get :@__tree_runner_microservice

          pi = _msvc.DEREFERENCE_PLUGIN :run_files

          once = -> do # assert that it's only called once just because
            rt = p[]
            once = nil
            rt
          end

          pi.send :define_singleton_method, :__quickie_runtime do
            once[]
          end

          pi
        end

        def build_fresh_dummy_runtime_

          # don't read from or write to the real life production runtime

          Home_::Quickie::Runtime___.define do |o|
            o.kernel_module = :_no_see_ts_
            o.toplevel_module = :_no_see_ts_
          end
        end

        # --

        def expression_agent
          send EXPAG___.fetch @API_OR_CLI
        end

        EXPAG___ = { API: :__expag_for_API, CLI: :__expag_for_CLI }

        def __expag_for_CLI
          ::Kernel._K
        end

        def __expag_for_API
          # (assume this guy is loaded:)
          # Home_::Quickie::TreeRunnerMicroservice::No_deps_zerk_[]
          ::NoDependenciesZerk::API_ExpressionAgent.instance
        end

        def prepare_subject_CLI_invocation invo
          NOTHING_
        end
        #
        def program_name_string_array
          PNSA___
        end
        PNSA___ = %w( ts quee )
        #
        def subject_CLI
          Home_::Quickie::API::CLI_for_RecursiveRunner
        end

        def prepare_subject_API_invocation invo
          invo
        end
        #
        def subject_API
          Home_::Quickie::API  # <-
        end
      # -

      # ==

      class DescribeProxy  # 1x
        def initialize & p
          @__once = p
        end
        def describe * s_a, & p
          remove_instance_variable( :@__once )[ p, s_a ]
        end
      end

      # ==

      CLI_lib___ = -> do
        Zerk_test_support_[]::Non_Interactive_CLI::Fail_Early
      end

      # ==
    end
  end
end
# #born as [ts] quickie plugins test support node; first ever hybrid CLI/API support
