require_relative '../core'
require 'skylab/test-support/core'
require 'skylab/headless/test/test-support'

module Skylab::Permute::TestSupport  # (was [#ts-010])

  Permute_ = ::Skylab::Permute
  Callback_ = Permute_::Callback_

  module TestLib_

    Headless__ = Callback_::Autoloader.build_require_sidesystem_proc :Headless

    Spy = -> do
      Callback_::TestSupport::Call_Digraph_Listeners_Spy
    end

    Unstyle = -> do
      Headless__[]::CLI::Pen::FUN.unstyle
    end
  end
end
