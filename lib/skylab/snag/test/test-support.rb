require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Snag::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  Snag_ = ::Skylab::Snag
  TestLib_ = ::Module.new
  TestSupport_ = ::Skylab::TestSupport

  module CONSTANTS
    Snag_ = Snag_
    TestSupport_ = TestSupport_
    TestLib_ = TestLib_
  end

  include CONSTANTS # in the body of child modules

  module TestLib_
    sidesys = Snag_::Autoloader_.build_require_sidesystem_proc
    Headless__ = sidesys[ :Headless ]
    Memoize = -> p do
      MetaHell__[]::FUN.memoize[ p ]
    end
    MetaHell__ = sidesys[ :MetaHell ]
    Tmpdir_pathname = -> do
      Headless__[]::System.defaults.tmpdir_pathname
    end
  end

  module InstanceMethods

    include CONSTANTS

    def debug!
      tmpdir.debug!
      @do_debug = true
    end

    attr_accessor :do_debug

    def from_tmpdir & p
      Snag_::Library_::FileUtils.cd tmpdir, verbose: do_debug, & p
    end

    -> x do
      define_method :tmpdir do x end
    end[ TestSupport_::Tmpdir.new TestLib_::Tmpdir_pathname[].join 'snaggle' ]

    -> x do
      define_method :manifest_path do x end
    end[ Snag_::API.manifest_path ]

  end
end
