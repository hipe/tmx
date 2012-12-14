require_relative '../core'
require 'skylab/test-support/core'


module Skylab::Issue::TestSupport
  ::Skylab::TestSupport::Regret[ Issue_TestSupport = self ]


  module CONSTANTS
    Headless = ::Skylab::Headless
    Issue = ::Skylab::Issue
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
      Issue::Services::FileUtils.cd( tmpdir, verbose: debug?, &block)
    end

    tmpdir = TestSupport::Tmpdir.new ::Skylab::TMPDIR_PATHNAME.join 'issues'
    define_method :tmpdir do
      tmpdir
    end

    def tmpdir_clear
      tmpdir.clear
    end
  end
end
