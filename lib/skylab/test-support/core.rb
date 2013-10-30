require File.expand_path('../../../skylab', __FILE__)
# above is [#bs-010]

require 'skylab/headless/core'

class ::String  # [#021] "to extlib or not to extlib.."

  def unindent                    # (has been called `deindent` in the past)
    gsub(/^#{::Regexp.escape(match(/\A(?<margin>[[:space:]]+)/)[:margin])}/, '')
                                  # note you will still have a trailing newline,
                                  # for which u could chop
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
