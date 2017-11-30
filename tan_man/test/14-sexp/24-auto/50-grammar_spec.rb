require_relative '../../test-support'

describe "[tm] sexp auto list pattern (grammar 50)", g: true do

  Skylab::TanMan::TestSupport[ self ]
  use :sexp_auto
  use :the_method_called_let

  using_grammar '50' do
    using_input '010-empty-digraph-no-ws.dot' do
      it_unparses_losslessly
      it "stmt_list is nil" do
        result = produce_result
        expect( result.stmt_list ).to eql nil
      end
    end

    using_input '100-one-arc.dot' do
      it_unparses_losslessly
      it "should not hiccup on whitespace" do
        expect( a.length ).to eql 1
        expect( a.first.unparse ).to eql 'Hello->World'
      end
    end

    using_input '200-two-arcs.dot' do
      it_unparses_losslessly
      it "does the list automagic" do
        expect( a.length ).to eql 2
        expect( a.first.unparse ).to eql 'foo->bar'
        expect( a.last.unparse ).to eql 'biff->baz'
      end
    end

    using_input '300-three-arcs.dot' do
      it_unparses_losslessly
      it 'does the list automagic for three items' do
        expect( a[0].unparse ).to eql 'One -> Two'
        expect( a[1].unparse ).to eql 'Three -> Four'
        expect( a[2].unparse ).to eql 'Five -> Six'
      end
    end
  end

  let(:a) do
    result = produce_result
    result.stmt_list.stmts
  end
end
