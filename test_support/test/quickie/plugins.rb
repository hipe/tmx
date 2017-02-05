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

        def expect_on_stderr s
          @CLI.expect_on_stderr s
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

        EXPECT___ = { API: :__expect_for_API, CLI: :__expect_for_CLI }

        def __expect_for_CLI a
          @CLI.expect( * a )
        end

        def __expect_for_API a, & p
          @API.expect_emission p, a
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
          API: :__expect_fail_for_API,
          CLI: :__expect_fail_for_CLI,
        }

        def __expect_fail_for_CLI
          @CLI.expect_fail_under self
        end

        def __expect_fail_for_API
          @API.expect_result_under NIL, self
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
          # #only-until-eventpoint
          _hi = @API.expect_result_under FALSE, self
          _hi
        end

        def expect_result x
          @API.expect_result_under x, self
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

      # ==

      CLI_lib___ = -> do
        Zerk_test_support_[]::Non_Interactive_CLI::Fail_Early
      end

      # ==
    end
  end
end
# #born as [ts] quickie plugins test support node; first ever hybrid CLI/API support
