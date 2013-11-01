require File.expand_path('../../../skylab', __FILE__)
# above is [#bs-010]

require 'skylab/headless/core'

class ::String  # [#022] "to extlib or not to extlib.."

  def unindent  # (formerly 'deindent')
    gsub! %r<^#{ ::Regexp.escape match( /\A[[:space:]]+/ )[ 0 ] }>, ''
    self
  end
end

module Skylab::TestSupport

  Autoloader = ::Skylab::Autoloader
  Headless = ::Skylab::Headless
  MetaHell = ::Skylab::MetaHell
  Subsys = self                   # gotcha: we cannot set the eponymous
                                  # #hiccup constant because there is a
                                  # legitimate other module ::SL::TS::TS.

  Stdout_ = -> { $stdout }        # littering our code with hard-coded globals
  Stderr_ = -> { $stderr }        # (or constants, that albeit point to a
                                  # resource like this (an IO stream)) is a
                                  # smell. we instead reference thme thru
                                  # these, which will at least point back to
                                  # this comment.

  ::Skylab::Subsystem[ self ]

end
