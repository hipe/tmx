require_relative '..'
require_relative '../callback/core'

module Skylab::Brazen

  class << self
    def bound_call rcvr, method_name, args=nil
      Bound_Call__.new rcvr, method_name, args
    end
    def model
      Brazen_::Model_::LIB
    end
  end

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  module Data_Stores_
    Autoloader_[ self, :boxxy ]
  end

  module Lib_
    memoize = -> p do
      p_ = -> do x = p[] ; p_ = -> { x } ; x end ; -> { p_[] }
    end
    sidesys = Autoloader_.build_require_sidesystem_proc
    EN_fun = -> do
      Headless__[]::SubClient::EN_FUN
    end
    Headless__ = sidesys[ :Headless ]
    JSON = memoize[ -> { require 'json' ; ::JSON  } ]
    N_lines = -> do
      Brazen_::Entity::Event::N_Lines
    end
    Name_function = -> do
      Snag__[]::Model_
    end
    Net_HTTP = memoize[ -> { require 'net/http' ; ::Net::HTTP } ]
    NLP = -> do
      Headless__[]::NLP
    end
    IO = -> do
      Headless__[]::IO
    end
    Snag__ = sidesys[ :Snag ]
    Text = -> do
      Snag__[]::Text
    end
  end

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  Actor_ = -> cls, * x_a do
    cls.include Entity_[]::Event::Builder_Methods
    Lib_::Snag__[]::Model_::Actor.via_client_and_iambic cls, x_a
  end

  ACHEIVED_ = true
  Brazen_ = self
  Bound_Call__ = ::Struct.new :receiver, :method_name, :args
  CONTINUE_ = nil
  DONE_ = true
  EMPTY_P_ = -> { }
  EMPTY_S_ = ''.freeze
  Entity_ = -> { Brazen_::Entity }
  Autoloader_[ Models_ = ::Module.new, :boxxy ]
  NAME_ = :name
  NILADIC_TRUTH_ = -> { true }
  SLASH_ = '/'.getbyte 0
  SPACE_ = ' '.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

  class Via_Proc_Event_Receiver_  # #todo this is from the future

    def initialize p
      @p = p
    end

    def receive_event ev
      @p[ ev ]
    end
  end
end
