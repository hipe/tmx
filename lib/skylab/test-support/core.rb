
class ::String  # :1:[#sl-131] [#022] "to extlib or not to extlib.."

  def unindent  # (formerly 'deindent')
    gsub! %r<^#{ ::Regexp.escape match( /\A[[:space:]]+/ )[ 0 ] }>, ''
    self
  end
end

require_relative '../callback/core'

module Skylab::TestSupport  # :[#021].

  def self.constant i
    self::Constants__.const_get i, false
  end

  Callback_ = ::Skylab::Callback
    Autoloader_ = Callback_::Autoloader
  EMPTY_A_ = [].freeze
  MONADIC_TRUTH_ = -> _ { true }
  TestSupport_ = self  # there is another module called ::SL::TS::TS

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :Lib_, 'library-'
  stowaway :System, 'library-'

end
