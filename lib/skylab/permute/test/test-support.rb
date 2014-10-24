require_relative '../core'
require 'skylab/test-support/core'
require 'skylab/headless/test/test-support'

module Skylab::Permute::TestSupport  # (was [#ts-010])

  TestLib_ = ::Module.new

  module Constants
    Callback_ = ::Skylab::Callback
    Permute_ = ::Skylab::Permute
    TestLib_ = TestLib_
    TestSupport_ = ::Skylab::TestSupport
  end

  include Constants

  # (no quickie - `after`)

  Callback_ = Callback_

  TestSupport_ = TestSupport_

  TestSupport_::Regret[ self ]

  module TestLib_

    HL__ = Callback_::Autoloader.build_require_sidesystem_proc :Headless

    Spy = -> do
      Callback_.test_support.call_digraph_listeners_spy
    end

    Unstyle = -> do
      HL__[]::CLI.pen.unstyle
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
end
