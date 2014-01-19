require_relative '..'
require 'skylab/face/core'
require 'skylab/headless/core'

module Skylab::FileMetrics

  [ :Face, :FileMetrics, :MetaHell, :Headless ].each do |c|
    const_set c, ::Skylab.const_get( c, false )
  end

  ::Skylab::Subsystem[ self ]

  %i( API Common Model Models Library_ ).each do |i|
    MAARS::Upwards[ const_set i, ::Module.new ]
  end

  module API  # #stowaway
    module Actions
      MetaHell::Boxxy[ self ]
    end
  end

  FUN = -> do  # #stowaway
    rx = /[ $']/
    ::Struct.new( :shellescape_path )[
      -> x do
        rx =~ x ? Library_::Shellwords.shellescape( x ) : x
      end
    ]
  end.call

  module Library_  # :+[#su-001]

    o = { }
    stdlib, subsys =
      ::Skylab::Subsystem::FUN.at :require_stdlib, :require_subsystem

    o[ :Basic ] = subsys
    o[ :FileUtils ] = o[ :Open3 ] = o[ :Shellwords ] = o[ :StringIO ] = stdlib
    o[ :StringScanner ] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do |const_i|
      if o.key? const_i
        const_set const_i, o.fetch( const_i )[ const_i ]
      else
        x = super const_i
        const_defined?( const_i, false ) or fail "scott whallan"
        x
      end
    end
  end
end
