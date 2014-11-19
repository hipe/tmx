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

  def self._lib
    @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
  end

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    HL__ = sidesys[ :Headless ]

    Ivars_with_procs_as_methods = -> cls do
      MH__[]::Ivars_with_Procs_as_Methods[ cls ]
    end

    MH__ = sidesys[ :MetaHell ]

    Old_CLI_lib = -> do
      HL__[]::CLI

    end

    Old_name_lib = -> do
      HL__[]::Name
    end

    Proxy_lib = -> do
      Callback_::Proxy
    end
  end

  LIB_ = _lib

  Headless = ::Skylab::Headless
  IDENTITY_ = -> { x }
  MetaHell = ::Skylab::MetaHell
  Treemap = self
  Treemap_ = self
  WRITE_MODE_ = 'w'.freeze

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]
end
