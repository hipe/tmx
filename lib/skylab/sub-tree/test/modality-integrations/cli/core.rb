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
        using_expect_stdout_stderr_invoke_via_argv argv
      end

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
