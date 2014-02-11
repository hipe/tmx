
class ::String  # :1:[#sl-131] [#022] "to extlib or not to extlib.."

  def unindent  # (formerly 'deindent')
    gsub! %r<^#{ ::Regexp.escape match( /\A[[:space:]]+/ )[ 0 ] }>, ''
    self
  end
end

require_relative '../callback/core'

module Skylab::TestSupport  # :[#021]

  Callback_ = ::Skylab::Callback
  Autoloader_ = Callback_::Autoloader

  MetaHell = Autoloader_.require_sidesystem :MetaHell

  TestSupport_ = self  # gotcha: we cannot set the eponymous
                                  # #hiccup constant because there is a
                                  # legitimate other module ::SL::TS::TS.


  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :Lib_, 'library-'
  stowaway :System, 'library-'

end
