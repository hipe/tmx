require_relative '../test-support'

module Skylab::TanMan::TestSupport::Models::DotFile::Parsing

  Parent_ = Skylab::TanMan::TestSupport::Models::DotFile

  Parent_[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def prepare_to_produce_result

      if ! Parent_.const_defined?( :Client, false )
        load ::File.join( Parent_.dir_pathname.to_path, 'client' )   # because new a.l borks because no extname. meh
      end

      @parse = Parent_::Client.new
      true
    end

    def module_with_subject_fixtures_node
      TS_
    end

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
  end

  Parent_module_name__ = -> do  # (is in and belongs in neither [ba] nor [br])
    rx = /[^:]+(?=::[^:]+\z)/
    -> mod do
      rx.match( mod.name )[ 0 ]
    end
  end.call

  SEXPS__ = 'Sexps'

end
# (WAS reference: http://solnic.eu/2014/01/14/custom-rspec-2-matchers.html)
