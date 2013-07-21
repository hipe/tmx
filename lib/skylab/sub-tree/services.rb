module Skylab::SubTree

  module Services

    stdlib, subsys = ::Skylab::Subsystem::FUN.
      at :require_stdlib, :require_subsystem
    o = { }
    o[:Basic] = subsys
    o[:Face] = subsys
    o[:FileUtils] = stdlib
    o[:Ncurses] = stdlib  # gemlib
    o[:Open3] = stdlib
    o[:Set] = stdlib
    o[:Shellwords] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }
    o[:TestSupport] = subsys

    define_singleton_method :const_missing do |c|
      const_set c, o.fetch( c )[ c ]
    end
  end
end
