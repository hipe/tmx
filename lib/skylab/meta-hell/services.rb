module Skylab::MetaHell

  module Services

    subsys = ::Skylab::Subsystem::FUN.require_subsystem
    o = { }
    o[:Basic] =
    o[:Headless] = subsys

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
