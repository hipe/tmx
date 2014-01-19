require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Headless::TestSupport

  ::Skylab::TestSupport::Regret[ Headless_TestSupport = self ]

  module CONSTANTS
    Headless = ::Skylab::Headless
    Headless_TestSupport = Headless_TestSupport
    MetaHell = ::Skylab::MetaHell
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS
  Headless = Headless ; TestSupport = TestSupport

  set_tmpdir_pathname do
    Headless::System.defaults.dev_tmpdir_pathname.join 'hl'
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
      TestSupport::Stderr_[]
    end
  end

  module Library_  # :+[#su-001]:just-for-tests
    h = {
      PubSub_TestSupport: -> do
        require 'skylab/pub-sub/test/test-support'
        ::Skylab::PubSub::TestSupport
      end
    }.freeze

    define_singleton_method :const_missing do |k|
      const_set k, h.fetch( k ).call
    end
  end

  CONSTANTS::FUN = -> do
    o = { }

    o[ :expect_text ] = -> emission do
      txt = emission.payload_x
      ::String === txt or fail "expected ::String had #{ txt.class }"
      txt
    end

    ::Struct.new( * o.keys ).new( * o.values )
  end.call

  NILADIC_TRUTH_ = -> { true }

end
