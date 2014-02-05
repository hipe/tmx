require File.expand_path('../../../skylab', __FILE__)
# above is [#bs-010]

require 'skylab/headless/core'
require 'skylab/meta-hell/core'

class ::String  # [#022] "to extlib or not to extlib.."

  def unindent  # (formerly 'deindent')
    gsub! %r<^#{ ::Regexp.escape match( /\A[[:space:]]+/ )[ 0 ] }>, ''
    self
  end
end

module Skylab::TestSupport  # (any future storypoints should go in [#021])

  Autoloader = ::Skylab::Autoloader
  Headless = ::Skylab::Headless
  MetaHell = ::Skylab::MetaHell
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
