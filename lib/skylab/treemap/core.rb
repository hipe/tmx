require_relative '..'
require 'skylab/callback/core'
require 'skylab/porcelain/core'

module Skylab::Treemap

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Bleeding = ::Skylab::Porcelain::Bleeding  # heavily depended upon for now

  module CLI
    Adapter = Bleeding::Adapter  # "ouroboros" ([#hl-069])

    def self.new *a, &b
      CLI::Client.new( *a, &b )   # a conventional delegation. conform to the
    end                           # standard that CLI.new always works.

    Autoloader_[ self ]
  end

  module Core
    Autoloader_[ self ]
    stowaway :Action, 'sub-client'
    stowaway :Event, 'sub-client'
  end

  module Plugins  # #stowaway
    Autoloader_[ self, :boxxy ]
  end

  module API
    module Actions
      Autoloader_[ self, :boxxy ]
    end
    Autoloader_[ self ]
  end

  IDENTITY_ = -> { x }
  Headless = ::Skylab::Headless
  MetaHell = ::Skylab::MetaHell
  Treemap = self
  WRITEMODE_ = 'w'.freeze

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]
end
