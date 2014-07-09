require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Snag::TestSupport
  ::Skylab::TestSupport::Regret[ Snag_TestSupport = self ]

  Snag_ = ::Skylab::Snag
  TestLib_ = ::Module.new
  TestSupport_ = ::Skylab::TestSupport

  module CONSTANTS
    MetaHell = ::Skylab::MetaHell
    Snag_ = Snag_
    TestSupport = ::Skylab::TestSupport
    TestLib_ = TestLib_
  end

  include CONSTANTS # in the body of child modules

  module TestLib_
    Headless__ = Snag_::Autoloader_.build_require_sidesystem_proc :Headless
    Tmpdir_pathname = -> do
      Headless__[]::System.defaults.tmpdir_pathname
    end
  end

  module InstanceMethods
    include CONSTANTS

    attr_accessor :do_debug

    def debug!
      tmpdir.debug!
      self.do_debug = true
    end

    def from_tmpdir &block
      Snag_::Library_::FileUtils.cd tmpdir, verbose: do_debug, &block
    end

    manifest_path = Snag_::API.manifest_path

    define_method :manifest_path do manifest_path end

    tmpdir = TestSupport_::Tmpdir.new TestLib_::Tmpdir_pathname[].join 'snaggle'

    define_method :tmpdir do
      tmpdir
    end

    def tmpdir_clear
      tmpdir.clear
    end
  end
end
