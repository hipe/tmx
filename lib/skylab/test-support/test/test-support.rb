require_relative '../core'

module Skylab::TestSupport::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestLib_ = ::Module.new

  module Constants
    EMPTY_A_ = TestSupport_::EMPTY_A_
    EMPTY_S_ = TestSupport_::EMPTY_S_
    LIB_  = TestSupport_.lib_
    TestLib_ = TestLib_
    TestSupport_ = TestSupport_
  end

  Constants::TS_TS_ = self

  include Constants

  TestSupport_::Regret[ self ]

  extend TestSupport_::Quickie

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      @debug_IO ||= TestSupport_.lib_.stderr
    end
  end

  module TestLib_

    Expect_event = -> test_ctx_cls do
      TestSupport_::Callback_.test_support::Expect_Event[ test_ctx_cls ]
    end

    Face_module = -> do
      TestSupport_::Lib_::Face__[]
    end

    Mock_FS = -> test_ctx_class do
      Callback_::Autoloader.require_sidesystem( :GitViz ).mock_FS[ test_ctx_class ]
    end

    Supernode_binfile = -> do
      TestSupport_::Autoloader_.require_sidesystem( :TMX ).supernode_binfile
    end

    System = -> do
      TestSupport_.lib_.system
    end
  end
end
