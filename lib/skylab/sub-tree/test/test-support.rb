require_relative '../core'

::Skylab::SubTree::Autoloader_.require_sidesystem :TestSupport

Skylab::TestSupport::Quickie.enable_kernel_describe
  # then we don't need to extend quick explicitly per test module ..
  # but this is just for easy legacy bridge-refactoring

module Skylab::SubTree::TestSupport

  module Constants
    Callback_ = ::Skylab::Callback
    SubTree_ = ::Skylab::SubTree
    TestSupport_ = ::Skylab::TestSupport
  end

  include Constants

  TestSupport_ = TestSupport_

  TestSupport_::Regret[ self ]

  module TestLib_

    sidesys = ::Skylab::SubTree::Autoloader_.
      method :build_require_sidesystem_proc

    HL__ = sidesys[ :Headless ]

    CLI_lib = -> do
      HL__[]::CLI
    end

    Face_ = sidesys[ :Face ]

    Stderr = -> do
      TestSupport_.debug_IO
    end
  end

  Constants::TestLib_ = TestLib_

  module InstanceMethods

    def debug_stream
      TestSupport_.debug_IO
    end

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end
  end
end
