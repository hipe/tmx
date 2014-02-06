require File.expand_path('../../../skylab', __FILE__)
# :+[#bs-010]  (and btw, is necessary b.c of a strong dependence on old a.l)

class ::String  # :1:[#sl-131] [#022] "to extlib or not to extlib.."

  def unindent  # (formerly 'deindent')
    gsub! %r<^#{ ::Regexp.escape match( /\A[[:space:]]+/ )[ 0 ] }>, ''
    self
  end
end

module Skylab::TestSupport  # :[#021]

  Autoloader = ::Skylab::Autoloader

  require_relative '../callback/core'
  Callback_ = ::Skylab::Callback

  Headless, MetaHell = Callback_::Autoloader.
    require_sidesystem :Headless, :MetaHell

  TestSupport_ = self                      # gotcha: we cannot set the eponymous
                                  # #hiccup constant because there is a
                                  # legitimate other module ::SL::TS::TS.

  Stdout_ = -> { ::STDOUT }       # littering our code with hard-coded globals
  Stderr_ = -> { ::STDERR }       # (or constants, that albeit point to a
                                  # resource like this (an IO stream)) is a
                                  # smell. we instead reference thme thru
                                  # these, which will at least point back to
                                  # this comment.

  ::Skylab::Subsystem[ self ]

end
