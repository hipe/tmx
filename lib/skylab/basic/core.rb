require_relative '..'
require 'skylab/meta-hell/core'

module Skylab::Basic

  # `Basic` is a centralized clearinghouse for the most basic of
  # datastructures, e.g tree-ish and table-ish. It is an experiment to
  # see if we can make these reusable enough not to hate this six months
  # from now. One day we will corral all the disparate such nerks into here,
  # maybe.

  %i| Basic MetaHell |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  MAARS = MetaHell::MAARS

  extend MAARS

  module Services

    o = { }
    stdlib, subproduct = MetaHell::FUN.at :require_stdlib, :require_subproduct
    o[:Headless] = subproduct # icky to reach in this direction, but only for 1
    o[:StringIO] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
