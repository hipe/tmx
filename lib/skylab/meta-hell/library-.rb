module Skylab::MetaHell

  Library_ = ::Skylab::Subsystem::Library.new MetaHell.dir_pathname  # :+[#su-001]
  module Library_

    stdlib, subsys = FUN.at :require_stdlib, :require_subsystem
    o = { }
    o[ :Basic ] =
    o[ :Callback ] =
    o[ :CodeMolester ] =
    o[ :Headless ] = subsys
    o[ :Open3 ] = stdlib
    o[ :Callback ] = subsys
    o[ :Set ] = o[ :Shellwords ] = stdlib

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end

  module Lib_
    memo = MetaHell::FUN::Memoize

    Callback__ = memo[ -> { Library_::Callback } ]

    Distill_proc = -> do
      Callback__[]::FUN::Distill_proc[]
    end
  end
end
