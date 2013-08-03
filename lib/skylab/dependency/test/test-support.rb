require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Dependency::TestSupport

  ::Skylab::TestSupport::Regret[ Dependency_TestSupport = self ]

  module CONSTANTS
    include ::Skylab::Dependency # include lots of constants
    Headless = ::Skylab::Headless # not used in application code
    MetaHell = ::Skylab::MetaHell
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS # include them for use in here, and in specs

  Headless = Headless # so they are visible in modules contained by this
  MetaHell = MetaHell # module, without polluting that module itself's n.s

  extend TestSupport::Quickie  # if you dare..

  tmpdir = TestSupport::Tmpdir.new Headless::System.defaults.tmpdir_path

  build_dir = TestSupport::Tmpdir.new tmpdir.join('build-dependency')

  fixtures_dir = Dependency_TestSupport.dir_pathname.join 'fixtures'

  file_server = TestSupport::Servers::Static_File_Server.new fixtures_dir,
    log_level_i: :info, # (:info | :warn) e.g.
    pid_path: tmpdir

  CONSTANTS::BUILD_DIR = build_dir # #bound
  CONSTANTS::FIXTURES_DIR = fixtures_dir # #bound
  CONSTANTS::FILE_SERVER = file_server # #bound

  module InstanceMethods

    extend MetaHell::Let::ModuleMethods
    include Headless::CLI::Pen::Methods # `unstyle`

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    -> do
      sdbg = $stderr
      define_method :dputs do |x|
        sdbg.puts x
      end
    end.call

    let(:fingers) { ::Hash.new { |h, k| h[k] = [] } }

  end
end
