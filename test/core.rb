require_relative '../lib/skylab'
require 'skylab/test-support/core'
require 'skylab/face/core'        # `pretty_path`, Tableize::I_M

module Skylab::Test

  # (setup this module for support used in both benchmarking and the
  # test runner - it's a big swath, but hopefull the core.rb files are
  # kept lightweight.)

  %i| Face Headless MetaHell Test TestSupport |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  UNIVERSAL_TEST_DIR_RELPATH_ = 'test'.freeze

  MetaHell::MAARS[ self ]

  stowaway :Benchmark, -> { TestSupport::Benchmark }

  SYSTEM_ = Headless::System.defaults

  Stderr_ = -> { $stderr }  # resources should not be accessed as contants
                            # or globals from within application code

  module Lib_
    Basic = -> do
      require 'skylab/basic/core' ; ::Skylab::Basic
    end
    Set = -> do
      require 'set' ; ::Set
    end
  end
end
