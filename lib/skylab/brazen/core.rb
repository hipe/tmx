require_relative '..'
require_relative '../callback/core'

module Skylab::Brazen

  class << self

    def bound_call *a
      if a.length.zero?
        Bound_Call__
      else
        Bound_Call__.new( *a )
      end
    end

    def event
      Brazen_::Entity.event
    end

    def model
      Brazen_::Model_::LIB
    end

    def model_entity model_class, & p
      Brazen_::Model_::Entity[ model_class, p ]
    end

    def node_identifier
      Brazen_::Kernel_::Node_Identifier__
    end
  end

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  module Data_Stores_
    class << self
      def name_function
        Models_::Datastore.name_function  # hack city
      end
    end
    Autoloader_[ self, :boxxy ]
  end

  module Lib_

    memoize = -> p do
      p_ = -> do x = p[] ; p_ = -> { x } ; x end ; -> { p_[] }
    end

    sidesys = Autoloader_.build_require_sidesystem_proc

    Ellipsify = -> * x_a do
      Snag__[]::CLI.ellipsify.via_arglist x_a
    end

    EN_fun = -> do
      Headless__[]::SubClient::EN_FUN
    end

    Headless__ = sidesys[ :Headless ]

    Iambic_scanner = -> do
      Callback_.iambic_scanner
    end

    JSON = memoize[ -> { require 'json' ; ::JSON  } ]

    N_lines = -> do
      Event_[]::N_Lines
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
    Lib_::Snag__[]::Model_::Actor.via_client_and_iambic cls, x_a
    Event_[].sender cls ; nil
  end

  ACHEIVED_ = true
  Brazen_ = self

  Bound_Call__ = ::Struct.new :receiver, :method_name, :args
  class << Bound_Call__
    def the_empty_call
      @tec ||= new EMPTY_P_, :call
    end
    def via_value x
      new -> { x }, :call
    end
  end

  Box_ = Callback_::Box
  CONTINUE_ = nil
  DASH_ = '-'.freeze
  DONE_ = true
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { }
  EMPTY_S_ = ''.freeze
  Entity_ = -> { Brazen_::Entity }
  Event_ = -> { Brazen_::Entity.event }
  Autoloader_[ Models_ = ::Module.new, :boxxy ]
  NAME_ = :name
  NILADIC_TRUTH_ = -> { true }
  PROCEDE_ = true
  SLASH_ = '/'.getbyte 0
  Scan_ = -> { Callback_::Scan }
  SPACE_ = ' '.freeze

  stowaway :TestSupport, 'test/test-support'

  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
