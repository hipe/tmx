require_relative '../core'
require 'skylab/test-support/core'

module Skylab::MetaHell::TestSupport
  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS # #ts-002
    MetaHell = ::Skylab::MetaHell
  end

  module InstanceMethods
    include CONSTANTS
    extend MetaHell::Let

    let :o do
      klass.new
    end
  end
end
