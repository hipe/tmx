require File.expand_path('../../../skylab', __FILE__)
# above is [#bs-010]

require 'skylab/headless/core'
require 'skylab/meta-hell/core'



class ::String                    # this is probably the only extlib you will
                                  # find org wide - give ::String this useful
                                  # thing used a lot in HEREDOCS in tests.

  def unindent                    # (has been called `deindent` in the past)
    gsub(/^#{::Regexp.escape(match(/\A(?<margin>[[:space:]]+)/)[:margin])}/, '')
                                  # note you will still have a trailing newline,
                                  # for which u could chop
  end
end



module Skylab::TestSupport

  Headless = ::Skylab::Headless
  MetaHell = ::Skylab::MetaHell
  TestSupport_ = self             # (do *not* set the convenience "hiccup"
                                  # eponymous constant here! there is a
                                  # legitimate other module called SL::TS::TS!)

  extend MetaHell::Autoloader::Autovivifying::Recursive
end
