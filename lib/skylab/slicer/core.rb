require_relative '..'
require 'skylab/callback/core'

module Skylab::Slicer

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  def self.lib_
    @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
  end

  module Lib_  # :+[#su-001]

    sidesys, = Autoloader_.at :build_require_sidesystem_proc

    API_action = -> do
      Face__[]::API::Action
    end

    CLI_client = -> do
      Face__[]::CLI::Client
    end

    Face__ = sidesys[ :Face ]
  end

  Slicer_ = self

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]
end
