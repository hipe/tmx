require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Dependency::TestSupport

  ::Skylab::TestSupport::Regret[ Dependency_TestSupport = self ]

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Dep_ = ::Skylab::Dependency

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  module TestLib_
    sidesys = Autoloader_.build_require_sidesystem_proc
    CLI = -> do
      Headless__[]::CLI
    end
    Headless__ = sidesys[ :Headless ]
    Let = -> do
      MetaHell__[]::Let
    end
    MetaHell__ = sidesys[ :MetaHell ]
    Tmpdir_path = -> do
      Headless__[]::System.defaults.tmpdir_path
    end
  end

  tmpdir = TestSupport_.tmpdir.new :path, TestLib_::Tmpdir_path[]

  build_dir = TestSupport_.tmpdir.new :path, tmpdir.join( 'build-dependency' )

  fixtures_dir = Dependency_TestSupport.dir_pathname.join 'fixtures'

  file_server = TestSupport_::Servers::Static_File_Server.new fixtures_dir,
    log_level_i: :info, # (:info | :warn) e.g.
    pid_path: tmpdir

  CONSTANTS::BUILD_DIR = build_dir # #bound
  CONSTANTS::FIXTURES_DIR = fixtures_dir # #bound
  CONSTANTS::FILE_SERVER = file_server # #bound

  module CONSTANTS
    Dep_ = Dep_
    TestSupport_ = TestSupport_
  end

  module InstanceMethods

    extend TestLib_::Let[]::ModuleMethods
    include TestLib_::CLI[]::Pen::Methods  # `unstyle`

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    -> do
      sdbg = ::STDERR
      define_method :dputs do |x|
        sdbg.puts x
      end
    end.call

    let(:fingers) { ::Hash.new { |h, k| h[k] = [] } }

  end
end
