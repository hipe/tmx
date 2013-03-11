require_relative '..'
require 'skylab/meta-hell/core'

module Skylab::Headless

  Autoloader = ::Skylab::Autoloader
  Headless = self
  MetaHell = ::Skylab::MetaHell
  MAARS = MetaHell::Autoloader::Autovivifying::Recursive

  module CONSTANTS

    MAXLEN = 4096  # (2 ** 12), the number of bytes in about 50 lines
                   # used as a heuristic or sanity in a couple places

    MUSTACHE_RX = / {{ ( (?: (?!}}) [^{] )+ ) }} /x

  end

  extend MAARS
end
