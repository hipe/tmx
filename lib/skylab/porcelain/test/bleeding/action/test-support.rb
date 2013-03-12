require_relative '../test-support'

module Skylab::Porcelain::TestSupport::Bleeding::Action

  ::Skylab::Porcelain::TestSupport::Bleeding[ Action_TestSupport = self ]

  include CONSTANTS # so we can say 'Bleeding' in specs!

  extend TestSupport::Quickie

end
