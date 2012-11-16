require_relative '../test-support'

module Skylab::Porcelain::TestSupport::Bleeding::Action
  _Parent = ::Skylab::Porcelain::TestSupport::Bleeding # #ts-002
  _Parent[ self ] # #regret
  Action_TestSupport = self # courtesy
  include _Parent::CONSTANTS # so we can say 'Bleeding' in specs!
end
