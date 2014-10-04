require_relative '../core'
require 'skylab/test-support/core'
require 'skylab/headless/test/test-support'

module Skylab::Permute::TestSupport  # (was [#ts-010])

  TestLib_ = ::Module.new
  module CONSTANTS
    Callback_ = ::Skylab::Callback
    Permute_ = ::Skylab::Permute
    TestLib_ = TestLib_
    TestSupport_ = ::Skylab::TestSupport
  end

  include CONSTANTS

  Callback_ = Callback_

  TestSupport_ = TestSupport_

  TestSupport_::Regret[ self ]

  module TestLib_

    Headless__ = Callback_::Autoloader.build_require_sidesystem_proc :Headless

    Spy = -> do
      Callback_::TestSupport::Call_Digraph_Listeners_Spy
    end

    Unstyle = -> do
      Headless__[]::CLI::Pen::FUN.unstyle
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
