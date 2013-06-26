require_relative '..'

require 'skylab/meta-hell/core'

module Skylab::Headless

  %i| Autoloader Headless MetaHell |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  MAARS = MetaHell::MAARS

  module CONSTANTS

    MAXLEN = 4096  # (2 ** 12), the number of bytes in about 50 lines
                   # used as a heuristic or sanity in a couple places
  end

  EMPTY_A_ = [ ].freeze

  extend MAARS
end
