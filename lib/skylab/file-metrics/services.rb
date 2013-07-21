module Skylab::FileMetrics

  module Services

    MAARS[ self ]

    o = { }
    stdlib = ::Skylab::Subsystem::FUN.require_stdlib
    o[:Open3] = stdlib
    o[:Shellwords] = stdlib
    o[:StringIO] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do |const_i|
      if o.key? const_i
        const_set const_i, o.fetch( const_i )[ const_i ]
      else
        ohai = super const_i
        if ! const_defined? const_i, false
          fail "scott whallan"
        end
        ohai
      end
    end
  end
end
