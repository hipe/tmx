require_relative '../core'

::Skylab::Cull::Autoloader_.require_sidesystem :TestSupport

module Skylab::Cull::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  module Constants
    Cull_ = ::Skylab::Cull
    TestSupport_ = ::Skylab::TestSupport
  end

  include Constants

  TestSupport_ = TestSupport_

  extend TestSupport_::Quickie

  Cull_ = Cull_

  module InstanceMethods

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end

    def event_expression_agent  # #hook-out for [br]
      Cull_::Brazen_.event.codifying_expression_agent
    end
  end

  Expect_event_ = -> test_context_module do
    Cull_::Brazen_.test_support::Expect_Event[ test_context_module ]
  end
end
