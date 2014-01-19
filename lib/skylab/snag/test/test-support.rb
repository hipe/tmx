require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Snag::TestSupport
  ::Skylab::TestSupport::Regret[ Snag_TestSupport = self ]

  module CONSTANTS
    Headless = ::Skylab::Headless
    MetaHell = ::Skylab::MetaHell
    Snag = ::Skylab::Snag
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS # in the body of child modules

  module InstanceMethods
    include CONSTANTS

    attr_accessor :do_debug

    def debug!
      tmpdir.debug!
      self.do_debug = true
    end

    def from_tmpdir &block
      Snag::Library_::FileUtils.cd tmpdir, verbose: do_debug, &block
    end

    manifest_path = Snag::API.manifest_path

    define_method :manifest_path do manifest_path end

    tmpdir = TestSupport::Tmpdir.new(
      Headless::System.defaults.tmpdir_pathname.join 'snaggle' )

    define_method :tmpdir do
      tmpdir
    end

    def tmpdir_clear
      tmpdir.clear
    end
  end
end
