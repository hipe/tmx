require_relative '../core'
require 'skylab/test-support/core'

module Skylab::Face::TestSupport

  module CONSTANTS
    Face = ::Skylab::Face
    TestSupport = ::Skylab::TestSupport
  end

  include CONSTANTS

  TestSupport::Regret[ self ]

  stowaway :CLI, 'cli/test-support'  # [#mh-030] for [#045]

  TestSupport::Sandbox::Host[ self ]

  CONSTANTS::Common_setup_ = -> do  # ..
    common = -> do
      include self::CONSTANTS
      extend TestSupport::Quickie
      self::Face = Face
    end
    h = {
      sandbox: -> do
        module self::Sandbox
        end
        self::CONSTANTS::Sandbox = self::Sandbox
      end,
      sandboxer: -> do
        self::Sandboxer = self::TestSupport::Sandbox::Spawner.new
      end
    }.freeze
    -> mod, *i_a do
      mod.module_exec( & common )
      while i_a.length.nonzero?
        i = i_a.shift
        mod.module_exec( & h.fetch( i ) )
      end
      nil
    end
  end.call
end
