require_relative '../core'
require 'skylab/test-support/core'

module Skylab::MetaHell::TestSupport
  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS
    MetaHell = ::Skylab::MetaHell
    TestSupport = ::Skylab::TestSupport
  end

  module ModuleMethods
    include CONSTANTS
    def memoize name, func
      define_method name, & MetaHell::FUN.memoize[ func ]
      nil
    end
  end

  module InstanceMethods
    include CONSTANTS
    extend MetaHell::Let

    let :o do
      klass.new
    end
  end
end
