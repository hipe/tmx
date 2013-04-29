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

  MAARS = ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive

  extend MAARS

  module Services

    o = { }

    o[:StringScanner] = -> { require 'strscan' ; ::StringScanner }

    o[:Headless] = -> { require 'skylab/headless/core' ; ::Skylab::Headless }
      # (the above is an icky direction to reach, but is only for 1 constant..)

    define_singleton_method :const_missing do |i|

      const_set i, o.fetch( i ).call

    end
  end
end
