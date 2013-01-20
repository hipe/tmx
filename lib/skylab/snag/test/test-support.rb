require_relative '../core'
require 'skylab/test-support/core'


module Skylab::Snag::TestSupport
  ::Skylab::TestSupport::Regret[ Snag_TestSupport = self ]


  module CONSTANTS
    Headless = ::Skylab::Headless
    Snag = ::Skylab::Snag
    TestSupport = ::Skylab::TestSupport
  end


  include CONSTANTS # in the body of child modules



  module InstanceMethods
    include CONSTANTS

    attr_accessor :do_debug

    alias_method :debug?, :do_debug

    def debug!
      tmpdir.debug!
      self.do_debug = true
    end

    def from_tmpdir &block
      Snag::Services::FileUtils.cd( tmpdir, verbose: debug?, &block)
    end

    manifest_path = Snag::API.manifest_path

    define_method :manifest_path do manifest_path end

    tmpdir = TestSupport::Tmpdir.new ::Skylab::TMPDIR_PATHNAME.join 'snaggle'

    define_method :tmpdir do
      tmpdir
    end

    def tmpdir_clear
      tmpdir.clear
    end
  end
end
