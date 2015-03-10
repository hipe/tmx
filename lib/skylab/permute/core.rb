require_relative '..'
require 'skylab/callback/core'

module Skylab::Permute

  class << self

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules Lib_, self
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  module Lib_

    memo, sidesys, req = Autoloader_.at :memoize,
      :build_require_sidesystem_proc, :require_sidesystem

    Bleeding__ = memo[ -> do
      req[ :Porcelain ]::Bleeding
    end ]

    CLI_Action = -> do
      Bleeding__[]::Action
    end

    CLI_Client = -> do
      Bleeding__[]::Runtime
    end

    CLI_lib = -> do
      HL__[]::CLI
    end

    HL__ = sidesys[ :Headless ]

    Table = -> do
      HL__[]::CLI::Table
    end
  end

  Permute_ = self

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

end
