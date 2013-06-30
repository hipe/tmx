module Skylab::MyTree

  module Services

    o = { }
    stdlib = MetaHell::FUN.require_stdlib
    o[:Find] = -> { require_relative 'services/find' }
    o[:Open3] = stdlib
    o[:OptionParser] = -> _ { require 'optparse' ; ::OptionParser }
    o[:Set] = stdlib
    o[:Shellwords] = stdlib
    o[:Time] = stdlib

    define_singleton_method :const_missing do |k|
      x = o.fetch( k )[ k ]
      if true == x
        if const_defined? k, false
          const_get k, false
        else
          super k
        end
      else
        const_set k, x
      end
    end
  end
end
