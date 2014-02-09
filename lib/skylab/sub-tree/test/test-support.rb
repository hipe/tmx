require_relative '../core'

::Skylab::SubTree::Autoloader_.require_sidesystem :TestSupport

Skylab::TestSupport::Quickie.enable_kernel_describe
  # then we don't need to extend quick explicitly per test module ..
  # but this is just for easy legacy bridge-refactoring

module Skylab::SubTree::TestSupport

  module CONSTANTS
    SubTree = ::Skylab::SubTree
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  TestSupport = TestSupport

  TestSupport::Regret[ self ]

  module Testlib_

    sidesys = ::Skylab::SubTree::Autoloader_.
      method :build_require_sidesystem_proc

    Headless__ = sidesys[ :Headless ]

    CLI_stylify = -> a, b do
      ::Skylab::SubTree::Lib_::CLI_stylify[ a, b ]
    end

    Face_ = sidesys[ :Face ]

    Parse_styles = -> s do  # TL
      Headless__[]::CLI::FUN::Parse_styles[ s ]
    end

    Stderr = -> do
      TestSupport::Stderr_[]
    end

    Unstyle_proc = -> do
      Headless__[]::CLI::Pen::FUN.unstyle
    end

    Unstyle_styled = -> x do
      Headless__[]::CLI::Pen::FUN::Unstyle_styled[ x ]
    end

    Unstyle_style_proc = -> do
      Headless__[]::CLI::Pen::FUN::Unstyle_styled
    end
  end

  CONSTANTS::Testlib_ = Testlib_

  module InstanceMethods

    def debug_stream
      TestSupport::Stderr_[]
    end

    attr_reader :do_debug

    def debug!
      @do_debug = true
    end
  end
end
