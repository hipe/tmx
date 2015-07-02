require_relative '../core'
require_relative '../..'
require 'skylab/test-support/core'

module Skylab::Headless::TestSupport

  ::Skylab::TestSupport::Regret[ TS_ = self ]

  TestLib_ = ::Module.new

  module Constants
    Home_ = ::Skylab::Headless
      Autoloader_ = Home_::Autoloader_
    TestLib_ = TestLib_
    TestSupport_ = ::Skylab::TestSupport
  end

  include Constants
  Home_ = Home_
  EMPTY_A_ = Home_::EMPTY_A_
  NILADIC_TRUTH_ = Home_::NILADIC_TRUTH_
  TestSupport_ = TestSupport_

  set_tmpdir_pathname do

    Home_.lib_.system.defaults.dev_tmpdir_pathname.join 'hl'

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

  module TestLib_

    Callback_test_support = -> do
      Home_::Callback_.test_support
    end

    Expect_event = -> test_context_class do
      Home_::Callback_.test_support::Expect_Event[ test_context_class ]
    end
  end
end
