require_relative '..'
require 'skylab/callback/core'

module Skylab::Slicer

  Autoloader_ = ::Skylab::Callback::Autoloader

  module Lib_  # :+[#su-001]

    sidesys, = Autoloader_.at :build_require_sidesystem_proc

    API_Action = -> do
      Face__[]::API::Action
    end

    CLI_Client = -> do
      Face__[]::CLI::Client
    end

    Face__ = sidesys[ :Face ]
  end

  Slicer_ = self

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]
end
