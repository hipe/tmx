require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Headless::TestSupport

  ::Skylab::TestSupport::Regret[ Headless_TestSupport = self ]

  self.tmpdir_pathname = ::Skylab::TMPDIR_PATHNAME.join 'hl'

  class FUN  # #abuse
    expect_text = -> emission do
      txt = emission.payload_x
      ::String === txt or fail "expected ::String had #{ txt.class }"
      txt
    end
    define_singleton_method :expect_text do expect_text end
  end

  module CONSTANTS
    FUN = FUN
    Headless = ::Skylab::Headless
    Headless_TestSupport = Headless_TestSupport
    MetaHell = ::Skylab::MetaHell
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS   # necessary
  Headless = Headless # necessary

  module ModuleMethods
    def debug!
      let( :do_debug ) { true }
    end
  end

  module InstanceMethods
    attr_accessor :do_debug

    def debug!
      self.do_debug = true
    end
  end

  module Services  # set up a Services::Foo_Bar to lazy load Foo_Bar only
                   # if it is needed. (it keeps "require" lines out of tests)
    h = {
      PubSub_TestSupport: -> do
        require 'skylab/pub-sub/test/test-support'
        ::Skylab::PubSub::TestSupport
      end
    }

    define_singleton_method :const_missing do |k|
      const_set k, h.fetch( k ).call
    end
  end
end
