require_relative '../core'

Skylab::Callback::Require_legacy_core_[]

require 'skylab/test-support/core'
require 'skylab/headless/core'  # unstyle etc

module Skylab::Callback::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  module CONSTANTS

    ::Skylab::MetaHell::FUN::Import_constants[
      ::Skylab, %i( Headless Callback TestSupport MetaHell ), self ]

  end

  include CONSTANTS

  Headless = Headless ; Callback = Callback

  module InstanceMethods

    -> do
      p = -> do
        pn = Callback::TestSupport.dir_pathname.join 'fixtures'
        p = -> { pn } ; pn
      end
      define_method :fixtures_dir_pn do
        p[]
      end
    end.call
  end

  IDENTITY_ = -> x { x }
end
