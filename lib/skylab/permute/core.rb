require_relative '..'
require 'skylab/callback/core'

module Skylab::Permute

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  module Lib_  # (:+[#su-001])

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

    Headless__ = sidesys[ :Headless ]

    Table = -> do
      Headless__[]::CLI::Table
    end
  end

  Permute_ = self

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

end
