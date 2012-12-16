require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Dependency::TestSupport
  extend ::Skylab::TestSupport::Regret[ Dependency_TestSupport = self ]

  module CONSTANTS
    include ::Skylab::Dependency # include lots of constants
    Headless = ::Skylab::Headless # not used in application code
    MetaHell = ::Skylab::MetaHell
  end

  include CONSTANTS # include them for use in here, and in specs

  Headless = Headless # so they are visible in modules contained by this
  MetaHell = MetaHell # module, without polluting that module itself's n.s


  tmpdir = ::Skylab::TestSupport::Tmpdir.new ::Skylab::TMPDIR_PATHNAME.to_s

  build_dir = ::Skylab::TestSupport::Tmpdir.new tmpdir.join('build-dependency')

  fixtures_dir = Dependency_TestSupport.dir_pathname.join 'fixtures'

  file_server = Dependency::StaticFileServer.new fixtures_dir,
    log_level: :info, # (:info | :warn) e.g.
    pid_path: tmpdir

  CONSTANTS::BUILD_DIR = build_dir # #bound
  CONSTANTS::FIXTURES_DIR = fixtures_dir # #bound
  CONSTANTS::FILE_SERVER = file_server # #bound

  module InstanceMethods
    extend MetaHell::Let::ModuleMethods
    include Headless::CLI::Stylize::Methods # `unstylize`

    attr_accessor :debug

    def debug!
      self.debug = true
    end

    let(:fingers) { ::Hash.new { |h, k| h[k] = [] } }

  end
end
