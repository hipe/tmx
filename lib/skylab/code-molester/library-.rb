module Skylab::CodeMolester

  module Services  # :+[#su-001]

    stdlib, subsystem = FUN.at :require_stdlib, :require_subsystem

    o = { }
    o[:Basic] = subsystem
    o[:Face] = subsystem
    o[:FileUtils] = stdlib
    o[:Headless] = subsystem
    o[:Psych] = stdlib
    o[:Set] = stdlib
    o[:StringIO] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }
    o[:Treetop] = -> _ { FUN.require_quietly[ 'treetop' ] ; ::Treetop }
    o[:YAML] = stdlib

    MAARS[ self ]  # LOOK.

    def self.const_missing c
      if H_.key? c
        const_set c, H_.fetch( c )[ c ]
      else
        super c
      end
    end
    H_ = o
  end
end
