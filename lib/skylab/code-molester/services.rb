module Skylab::CodeMolester

  module Services # being #watched [#mh-011] (this is instance four)

    o = { }
    stdlib, subproduct = MetaHell::FUN.at :require_stdlib, :require_subproduct
    o[:Basic] = subproduct
    o[:Face] = subproduct
    o[:FileUtils] = stdlib
    o[:Psych] = stdlib
    o[:StringIO] = stdlib
    o[:StringScanner] = -> _ { require 'strscan' ; ::StringScanner }
    o[:Treetop] = -> _ do
      MetaHell::FUN.require_quietly[ 'treetop' ]
      ::Treetop
    end
    o[:YAML] = stdlib

    extend MAARS  # LOOK.

    define_singleton_method :const_missing do |const_i|
      if o.key? const_i
        const_set const_i, o.fetch( const_i )[ const_i ]
      else
        super const  # KRAY!
      end
    end
  end
end
