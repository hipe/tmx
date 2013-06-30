module Skylab::MetaHell

  module Services

    o = { }
    subproduct = MetaHell::FUN.require_subproduct
    o[:Headless] = subproduct

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
