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

  ::Skylab::Subsystem[ self ]

  module Services

    subsystem, stdlib = ::Skylab::Subsystem::FUN.
      at :require_subsystem, :require_stdlib

    o = { }
    o[:Headless] = subsystem
    o[:StringIO] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do |c|
      const_set c, o.fetch( c )[ c ]
    end
  end
end
