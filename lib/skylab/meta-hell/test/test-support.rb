require_relative '../core'
require 'skylab/test-support/core'

module Skylab::MetaHell::TestSupport
  ::Skylab::TestSupport::Regret[ self ]

  MetaHell = ::Skylab::MetaHell

  module InstanceMethods
    extend MetaHell::Let

    let :o do
      klass.new
    end
  end
end
