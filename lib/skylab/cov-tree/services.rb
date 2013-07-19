module Skylab::CovTree

  module Services

    o = { }
    stdlib, subsys = MetaHell::FUN.at( :require_stdlib, :require_subproduct )
    o[:Basic] = subsys
    o[:Face] = subsys
    o[:FileUtils] = stdlib
    o[:Ncurses] = stdlib  # gemlib
    o[:Open3] = stdlib
    o[:Set] = stdlib
    o[:Shellwords] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }
    o[:TestSupport] = subsys

    define_singleton_method :const_missing do |const_i|
      const_set const_i, o.fetch( const_i )[ const_i ]
    end
  end
end
