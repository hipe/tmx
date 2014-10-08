require_relative '../core'
require_relative '../..'
require 'skylab/test-support/core'

module Skylab::Headless::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  module CONSTANTS
    Headless_ = ::Skylab::Headless
      Autoloader_ = Headless_::Autoloader_
    TestSupport_ = ::Skylab::TestSupport
  end

  include CONSTANTS
  Headless_ = Headless_
  EMPTY_A_ = Headless_::EMPTY_A_
  NILADIC_TRUTH_ = Headless_::NILADIC_TRUTH_
  TestSupport_ = TestSupport_

  set_tmpdir_pathname do
    Headless_::System.defaults.dev_tmpdir_pathname.join 'hl'
    #todo - when you take out the `dev_` above it fails
  end

  module ModuleMethods
    def debug!
      let :do_debug do true end
    end
  end

  module InstanceMethods

    def debug!
      self.do_debug = true
    end
    attr_accessor :do_debug

    def debug_IO
      TestSupport_.debug_IO
    end
  end

  module TestLib_  # :+[#su-001]:just-for-tests

    Callback_test_support = -> do
      require 'skylab/callback/test/test-support'
      Headless_::Callback_::TestSupport
    end

  end
end
