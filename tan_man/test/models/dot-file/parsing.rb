module Skylab::TanMan::TestSupport

  module Models::Dot_File::Parsing

    def self.[] tcc

      Models::Dot_File[ tcc ]

      tcc.include self
    end

    define_method :fixtures_path_, ( Lazy_.call do

      ::File.join TS_.dir_path, 'fixture-dot-files-for-parsing'
    end )

    def expect_digraph_document_sexp
      x = result
      part = Parent_module_name__[ x.class ]
      if SEXPS__ == part
        if :graph != x.class.expression_symbol
          fail "expected 'graph', had '#{ x.class.expression_symbol }'"
        end
      else
        fail "expected containing moudle to be '#{ SEXPS__ }', had #{ part }"
      end
    end
    # <-

  Parent_module_name__ = -> do  # (is in and belongs in neither [ba] nor [br])
    rx = /[^:]+(?=::[^:]+\z)/
    -> mod do
      rx.match( mod.name )[ 0 ]
    end
  end.call

  SEXPS__ = 'Sexps'

  # ->

  end
end
# (WAS reference: http://solnic.eu/2014/01/14/custom-rspec-2-matchers.html)
