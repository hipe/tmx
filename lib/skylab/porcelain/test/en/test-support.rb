require_relative '../test-support'

Skylab::Porcelain::En::ApiActionInflectionHack # force/test autolaod (nec) :(

module Skylab::Porcelain::TestSupport::En
  Parent_ = ::Skylab::Porcelain::TestSupport # for #ts-002
  Parent_[ self ] # #regret
  En_TestSupport = self # courtesy

  module CONSTANTS
    include Parent_::CONSTANTS
    En = ::Skylab::Porcelain::En
  end

  include CONSTANTS # so that `En` (the right one) can be accessed
end
