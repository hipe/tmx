require 'skylab/task_examples'
require 'skylab/test_support'

module Skylab::TaskExamples::TestSupport

   Dependency_TestSupport = self
  ::Skylab::TestSupport::Regret[ self, ::File.dirname( __FILE__ )]

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Home_ = ::Skylab::TaskExamples

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  module TestLib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Brazen = sidesys[ :Brazen ]

    CLI_lib = -> do
      HL__[]::CLI
    end

    HL__ = sidesys[ :Headless ]

    System = -> do
      System_lib___[].services
    end

    System_lib___ = sidesys[ :System ]

    Tmpdir_path = -> do
      System[].filesystem.tmpdir_path
    end
  end

  tmpdir = TestSupport_.tmpdir.new_with(
    :path, TestLib_::Tmpdir_path[] )

  build_dir = TestSupport_.tmpdir.new_with(
    :path, tmpdir.join( 'build-dependency' ) )

  fixtures_dir = Dependency_TestSupport.dir_pathname.join 'fixtures'

  file_server = TestSupport_::Servers::Static_File_Server.new fixtures_dir,
    log_level_i: :info, # (:info | :warn) e.g.
    pid_path: tmpdir

  Constants::BUILD_DIR = build_dir # #bound
  Constants::FIXTURES_DIR = fixtures_dir # #bound
  Constants::FILE_SERVER = file_server # #bound

  module Constants
    Home_ = Home_
    TestSupport_ = TestSupport_
  end

  module InstanceMethods

    define_method :unstyle, TestLib_::Brazen[]::CLI::Styling::Unstyle

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
