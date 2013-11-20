require_relative '../core'
require 'skylab/test-support/core'
require 'skylab/headless/core'  # unstyle etc

module Skylab::PubSub::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS

    ::Skylab::MetaHell::FUN::Import_constants[
      ::Skylab, %i( Headless PubSub TestSupport MetaHell ), self ]

  end

  include CONSTANTS

  Headless = Headless ; PubSub = PubSub

  module InstanceMethods

    -> do
      p = -> do
        pn = PubSub::TestSupport.dir_pathname.join 'fixtures'
        p = -> { pn } ; pn
      end
      define_method :fixtures_dir_pn do
        p[]
      end
    end.call
  end

  IDENTITY_ = -> x { x }
end
