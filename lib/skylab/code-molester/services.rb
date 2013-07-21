module Skylab::CodeMolester

  module Services # being #watched [#mh-011] (this is instance four)

    stdlib, subsystem = FUN.at :require_stdlib, :require_subsystem

    o = { }
    o[:Basic] = subsystem
    o[:Face] = subsystem
    o[:FileUtils] = stdlib
    o[:Psych] = stdlib
    o[:StringIO] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }
    o[:Treetop] = -> _ { FUN.require_quietly[ 'treetop' ] ; ::Treetop }
    o[:YAML] = stdlib

    MAARS[ self ]  # LOOK.

    def self.const_missing c
      if H_.key? c
        const_set c, H_.fetch( c )[ c ]
      else
        super const  # KRAY!
      end
    end
    H_ = o
  end
end
