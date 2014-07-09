require_relative '..'
require 'skylab/callback/core'

module Skylab::BeautySalon

  Autoloader_ = ::Skylab::Callback::Autoloader

  module Lib_

    sidesys, = Autoloader_.at :build_require_sidesystem_proc

    API_Action = -> do
      Face__[]::API::Action
    end

    Basic__ = sidesys[ :Basic ]

    CLI_Client = -> do
      Face__[]::CLI::Client
    end

    Ellipsify = -> do
      Headless__[]::CLI::FUN::Ellipsify_
    end

    Face__ = sidesys[ :Face ]

    Function_class = -> do
      MetaHell__[]::Function::Class
    end

    Headless__ = sidesys[ :Headless ]

    List_scanner = -> x do
      Basic__[]::List::Scanner[ x ]
    end

    MetaHell__ = sidesys[ :MetaHell ]

    Plugin = -> do
      Face__[]::Plugin
    end

    Positive_range = -> do
      Basic__[]::Range::Positive
    end

    Token_buffer = -> x, y do
      Basic__[]::Token::Buffer.new x, y
    end
  end

  # (:+[#su-001]:none)

  BeautySalon_ = self

  IDENTITY_ = -> x { x }          # for fun we track this

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

end
