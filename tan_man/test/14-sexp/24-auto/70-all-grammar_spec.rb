require_relative '../../test-support'

describe "[tm] sexp auto list pattern (grammars 70*)", g: true do

  Skylab::TanMan::TestSupport[ self ]
  use :sexp_auto

  # #cov2.3

  using_grammar '70-50-bughunt' do
    using_input 'foop-foop' do
      it 'does not do infinite recursion' do
        expect( result.unparse ).to eql "foop ; foop ;\n"
      end
    end
  end

  using_grammar '70-75-minimal-recursive-list' do
    using_input 'feep-forp' do
      it 'enumerates the nodes' do
        expect( result.unparse ).to eql "feep ; forp ;\n"
        a = result.nodes.to_a  # to_item_array_
        expect( a.length ).to eql 2
        expect( a ).to eql [ 'feep', 'forp' ]
      end
    end
  end

  using_grammar '70-simple-recursive-list' do
    using_input '3-three' do
      it 'gets the agent names of each statement' do
        expect( result.map(&:agent) ).to eql [ 'Joanna', 'Toby', 'Moot' ]
      end
    end
  end
end
