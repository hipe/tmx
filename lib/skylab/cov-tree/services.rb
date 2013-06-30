module Skylab::CovTree

  module Services

    o = { }
    stdlib = MetaHell::FUN.require_stdlib
    o[:FileUtils] = stdlib
    o[:Open3] = stdlib
    o[:Set] = stdlib
    o[:Shellwords] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
