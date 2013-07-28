module Skylab::MetaHell

  Services = ::Skylab::Subsystem::Services.new MetaHell.dir_pathname
  module Services

    stdlib, subsys = FUN.at :require_stdlib, :require_subsystem
    o = { }
    o[:Basic] =
    o[:CodeMolester] =
    o[:Headless] = subsys
    o[:Open3] =
    o[:Shellwords] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
