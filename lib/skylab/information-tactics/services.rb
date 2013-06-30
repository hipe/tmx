module Skylab::InformationTactics

  module Services

    o = { }
    stdlib = MetaHell::FUN.require_stdlib
    o[:Time] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
