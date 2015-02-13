require_relative '../core'

module Skylab::Basic

  module TestSupport

    TestLib_ = ::Module.new

    module Constants
      Basic_ = ::Skylab::Basic
      TestLib_ = TestLib_
      TestSupport_ = Autoloader_.require_sidesystem :TestSupport
    end

    include Constants

    TestSupport_ = TestSupport_

    TestSupport_::Regret[ self ]

    TestSupport_::Sandbox::Host[ self ]

    module TestLib_

      Expect_event = -> test_ctxt_cls do
        Basic_::Callback_.test_support::Expect_Event[ test_ctxt_cls ]
      end

      Expect_normalization = -> test_ctxt_cls do
        Basic_::TestSupport::Expect_Normalization[ test_ctxt_cls ]
      end
    end

    module InstanceMethods

      def debug!
        @do_debug = true
      end

      attr_reader :do_debug

      def debug_IO
        TestSupport_.debug_IO
      end

      def black_and_white_expression_agent_for_expect_event
        Basic_.lib_.brazen::API.expression_agent_instance
      end
    end
  end
end
