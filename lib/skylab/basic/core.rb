require_relative '..'
require 'skylab/meta-hell/core'

module Skylab::Basic  # introduction at [#020]

  %i| Basic MetaHell |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  ::Skylab::Subsystem[ self ]

  module Services

    subsystem, stdlib = ::Skylab::Subsystem::FUN.
      at :require_subsystem, :require_stdlib

    o = { }
    o[ :Headless ] = subsystem
    o[ :Set ] =
      o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do |c|
      const_set c, o.fetch( c )[ c ]
    end
  end

  stowaway :String, 'string/fun'

end
