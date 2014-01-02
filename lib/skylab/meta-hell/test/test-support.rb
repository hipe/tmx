require_relative '../core'
require 'skylab/test-support/core'

module Skylab::MetaHell::TestSupport

  ::Skylab::TestSupport::Regret[ self ]
  ::Skylab::TestSupport::Quickie.enable_kernel_describe

  module CONSTANTS
    MetaHell = ::Skylab::MetaHell
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  MetaHell = MetaHell

  module ModuleMethods
    include CONSTANTS
    def memoize name_i, p
      define_method name_i, & MetaHell::FUN.memoize[ p ]
      nil
    end
  end

  module InstanceMethods
    include CONSTANTS
    extend MetaHell::Let

    def debug!
      @do_debug = true
    end

    attr_reader :do_debug

    def debug_IO
      MetaHell::Services::Headless::System::IO.some_stderr_IO
    end

    let :o do
      klass.new
    end
  end
end
