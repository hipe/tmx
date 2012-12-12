require_relative '../core'
require 'skylab/test-support/core'
require 'skylab/headless/test/test-support' # unstylize_if_stylized

module Skylab::Dependency::TestSupport
  extend ::Skylab::TestSupport::Regret[ Dependency_TestSupport = self ]

  module CONSTANTS
    include ::Skylab::Dependency # include lots of constants
    MetaHell = ::Skylab::MetaHell # not used in application code
  end

  include CONSTANTS # include them for use in here, and in specs

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
    extend CONSTANTS::MetaHell::Let::ModuleMethods
    include ::Skylab::Headless::TestSupport::InstanceMethods # see

    let(:fingers) { ::Hash.new { |h, k| h[k] = [] } }

  end
end
