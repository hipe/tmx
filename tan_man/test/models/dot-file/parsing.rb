module Skylab::TanMan::TestSupport

  module Models::Dot_File::Parsing

    def self.[] tcc

      Models::Dot_File[ tcc ]

      tcc.include self
    end

    define_method :fixtures_path_, ( Common_.memoize do

      ::File.expand_path "../#{ FIXTURES_ENTRY_ }", __FILE__
    end )

    def expect_digraph_document_sexp
      x = result
      part = Parent_module_name__[ x.class ]
      if SEXPS__ == part
        if :graph != x.class.expression
          fail "expected 'graph', had '#{ x.class.expression }'"
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
