require_relative 'test-support'

describe "[tm] sexp auto list pattern (grammars 70*)", g: true do

  extend ::Skylab::TanMan::TestSupport::Sexp::Auto

  using_grammar '70-50-bughunt' do
    using_input 'foop-foop' do
      it 'does not do infinite recursion' do
        result.unparse.should eql("foop ; foop ;\n")
      end
    end
  end

  using_grammar '70-75-minimal-recursive-list' do
    using_input 'feep-forp' do
      it 'enumerates the nodes' do
        result.unparse.should eql("feep ; forp ;\n")
        a = result.nodes.to_a  # _items
        a.length.should eql(2)
        a.should eql(['feep', 'forp'])
      end
    end
  end

  using_grammar '70-simple-recursive-list' do
    using_input '3-three' do
      it 'gets the agent names of each statement' do
        result.map(&:agent).should eql(["Joanna", "Toby", "Moot"])
      end
    end
  end
end
