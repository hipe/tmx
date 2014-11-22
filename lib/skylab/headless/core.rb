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
      Headless_::SubClient.expression_agent
    end

    def _lib
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end

    def system
      @system ||= Headless_::System__::Front.new
    end
  end

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  ACHIEVED_ = true
  COLON_ = ':'.freeze
  CONST_SEP_ = '::'.freeze
  DASH_ = '-'.freeze
  DASH_BYTE_ = DASH_.getbyte 0
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  Headless_ = self
  IDENTITY_ = -> x { x }
  stowaway :Lib_, 'library-'
  LINE_SEPARATOR_STRING_ = "\n".freeze
  MONADIC_EMPTINESS_ = -> _ {}
  MONADIC_TRUTH_ = -> _ { true }
  NEWLINE_ = LINE_SEPARATOR_STRING_
  NILADIC_TRUTH_ = -> { true }
  PROCEDE_ = true
  READ_MODE_ = 'r'.freeze
  Scn_ = Scn = Callback_::Scn
  SPACE_ = ' '.freeze
  TERM_SEPARATOR_STRING_ = SPACE_
  WRITE_MODE_ = 'w'.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
