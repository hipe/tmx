module Skylab::MetaHell

  Library_ = ::Skylab::Subsystem::Library.new MetaHell.dir_pathname  # :+[#su-001]
  module Library_

    stdlib, subsys = FUN.at :require_stdlib, :require_subsystem
    o = { }
    o[ :Basic ] = o[ :CodeMolester ] = o[ :Headless ] = subsys
    o[ :Open3 ] = stdlib
    o[ :PubSub ] = subsys
    o[ :Set ] = o[ :Shellwords ] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
