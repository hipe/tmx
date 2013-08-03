require_relative '../core'
require 'skylab/test-support/core'
require 'skylab/headless/core'  # unstyle etc

module Skylab::PubSub::TestSupport
  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS
    %i| Headless PubSub TestSupport MetaHell |.each do |i|
      const_set i, ::Skylab.const_get( i )
    end
  end

  Headless = CONSTANTS::Headless  # so that h.l is visible in all modules
                                  # lexically scoped under this one.
                                  # (necessary for e.g in Nub)

  include CONSTANTS

  PubSub = PubSub  # yeah

  module InstanceMethods

    def fixtures_dir_pn
      PubSub::TestSupport.dir_pathname.join( 'fixtures' )
    end
  end

  IDENTITY_ = -> x { x }
end
