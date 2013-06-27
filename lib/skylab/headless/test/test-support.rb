require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Headless::TestSupport

  ::Skylab::TestSupport::Regret[ Headless_TestSupport = self ]

  self.tmpdir_pathname = ::Skylab.tmpdir_pathname.join 'hl'

  module CONSTANTS
    Headless = ::Skylab::Headless
    Headless_TestSupport = Headless_TestSupport
    MetaHell = ::Skylab::MetaHell
    TestSupport = ::Skylab::TestSupport
  end

  Headless = ::Skylab::Headless  # covered

  module ModuleMethods
    def debug!
      let :do_debug do true end
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

end
