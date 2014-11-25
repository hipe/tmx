require_relative '../core'

module Skylab::TestSupport::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  module Constants
    EMPTY_A_ = TestSupport_::EMPTY_A_
    EMPTY_S_ = TestSupport_::EMPTY_S_
    LIB_  = TestSupport_._lib
    TestSupport_ = TestSupport_
  end

  Constants::TS_TS_ = self

  include Constants

  TestSupport_::Regret[ self ]

  module InstanceMethods

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end

    def debug_IO
      @debug_IO ||= TestSupport_._lib.stderr
    end
  end

  module TestLib_

    Face_module = -> do
      TestSupport_::Lib_::Face__[]
    end

    Supernode_binfile = -> do
      TestSupport_::Autoloader_.require_sidesystem( :TMX ).supernode_binfile
    end

    System = -> do
      TestSupport_._lib.system
    end
  end
end
