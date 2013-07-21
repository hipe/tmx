module Skylab::InformationTactics

  module Services

    stdlib = ::Skylab::Subsystem::FUN.require_stdlib
    o = { }
    o[:Time] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
