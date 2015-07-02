require_relative '../callback/core'

if ! ::Object.private_method_defined? :notificate
  class ::Object  # :2:[#sl-131] - experiment. this is the last extlib.
  private
    def notificate i
    end
  end
end

module Skylab::Headless  # ([#013] is reserved for a core node narrative - no storypoints yet)

  class << self

    def expression_agent
      Home_::SubClient.expression_agent
    end

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  ACHIEVED_ = true
  COLON_ = ':'.freeze
  CONST_SEP_ = '::'.freeze
  DASH_ = '-'.freeze
  DASH_BYTE_ = DASH_.getbyte 0
  EMPTY_A_ = [].freeze
  EMPTY_S_ = ''.freeze
  Home_ = self
  IDENTITY_ = -> x { x }
  stowaway :Library_, 'lib-'
  LINE_SEPARATOR_STRING_ = "\n".freeze
  MONADIC_EMPTINESS_ = -> _ {}
  MONADIC_TRUTH_ = -> _ { true }
  NEWLINE_ = LINE_SEPARATOR_STRING_
  NIL_ = nil
  NILADIC_TRUTH_ = -> { true }
  PROCEDE_ = true
  Scn_ = Callback_::Scn
  SPACE_ = ' '.freeze
  TERM_SEPARATOR_STRING_ = SPACE_
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
