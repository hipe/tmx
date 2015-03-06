require_relative 'test-support'

module Skylab::SubTree::TestSupport::Modality_Integrations::CLI

  module Expect_expression

    class << self

      def [] test_context_module

        test_context_module.include Instance_Methods
        NIL_
      end
    end  # >>

    module Instance_Methods

      include TestSupport_::Expect_Stdout_Stderr::InstanceMethods

      # (adpated from [br])

      def invoke * argv
        invoke_via_argv argv
      end

      def invoke_via_argv argv

        @exitstatus = __produce_CLI_client.invoke argv

        NIL_
      end

      def __produce_CLI_client

        g = TestSupport_::IO.spy.group.new

        g.do_debug_proc = -> do
          do_debug
        end

        g.debug_IO = debug_IO

        io = use_this_as_stdin
        if io
          g.add_stream :i, io
        else
          g.add_stream :i, :__instream_not_used_yet__
        end

        g.add_stream :o
        g.add_stream :e

        @IO_spy_group_for_expect_stdout_stderr = g

        subject_CLI.new( * g.values_at( :i, :o, :e ),
          invocation_strings_for_expect_expression )

      end

      attr_reader :use_this_as_stdin

      -> do

        generic_exitstatus = 5  # meh

        define_method :expect_errored_generically do
          expect_no_more_lines
          @exitstatus.should eql generic_exitstatus
        end

      end.call  # etc

      def expect_succeeded
        expect_no_more_lines
        expect_success_result
      end

      def expect_success_result
        @exitstatus.should be_zero
      end
    end
  end
end
