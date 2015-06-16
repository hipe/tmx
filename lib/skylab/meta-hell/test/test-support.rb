require_relative '../core'
require 'skylab/test-support/core'

module Skylab::MetaHell::TestSupport

  # (this file is :+#temporary-to-this-phase)

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ self ]

  module ModuleMethods

    def memoize_ sym, & p
      define_method sym, Callback_.memoize( & p )
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
  end

  Callback_ = ::Skylab::Callback
  MetaHell_ = ::Skylab::MetaHell

  module Constants

    Callback_ = Callback_
    MetaHell_ = MetaHell_
    TestSupport_ = TestSupport_
  end
end
