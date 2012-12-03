require_relative '../test-support'

Skylab::Porcelain::En::ApiActionInflectionHack || nil # #annoy

module Skylab::Porcelain::TestSupport::En
  ::Skylab::Porcelain::TestSupport[ En_TestSupport = self ] #regret, #courtesy

  module CONSTANTS
    En = ::Skylab::Porcelain::En
  end

  include CONSTANTS # so that `En` (the right one) can be accessed
end
