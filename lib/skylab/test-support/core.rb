
class ::String  # :1:[#sl-131] [#022] "to extlib or not to extlib.."

  def unindent  # (formerly 'deindent')
    gsub!(
      %r<^#{ ::Regexp.escape match( /\A[[:space:]]+/ )[ 0 ] }>,
      ::Skylab::TestSupport::EMPTY_S_ )
    self
  end
end

require_relative '../callback/core'

module Skylab::TestSupport  # :[#021].

  class << self

    def constant i
      self::Constants__.const_get i, false
    end

    def debug_IO
      self::Lib_::Stderr[]
    end

    def _lib
      @lib ||= TestSupport_::Lib_::INSTANCE
    end

    def spec_rb
      TestSupport_::Init.spec_rb
    end

    def tmpdir
      self::Lib_::Tmpdir[]
    end
  end

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  ACHIEVED_ = true
  CONST_SEP_ = '::'.freeze
  DASH_ = '-'.freeze
  DOT_DOT_ = '..'.freeze
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  FILE_SEP_ = ::File::SEPARATOR
  KEEP_PARSING_ = true
  stowaway :Lib_, 'library-'
  MONADIC_TRUTH_ = -> _ { true }
  NEWLINE_ = "\n".freeze
  TEST_DIR_FILENAME_ = 'test'.freeze
  TestSupport_ = self  # there is another module called ::SL::TS::TS
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze

end
