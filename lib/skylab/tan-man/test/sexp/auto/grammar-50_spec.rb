require_relative 'test-support'

describe "[tm] Sexp::Auto list pattern (grammar 50)", g: true do

  extend ::Skylab::TanMan::TestSupport::Sexp::Auto

  using_grammar '50' do
    using_input '010-empty-digraph-no-ws.dot' do
      it_unparses_losslessly
      it "stmt_list is nil" do
        result = produce_result
        result.stmt_list.should eql(nil)
      end
    end

    using_input '100-one-arc.dot' do
      it_unparses_losslessly
      it "should not hiccup on whitespace" do
        a.length.should eql(1)
        a.first.unparse.should eql('Hello->World')
      end
    end

    using_input '200-two-arcs.dot' do
      it_unparses_losslessly
      it "does the list automagic" do
        a.length.should eql(2)
        a.first.unparse.should eql('foo->bar')
        a.last.unparse.should eql('biff->baz')
      end
    end

    using_input '300-three-arcs.dot' do
      it_unparses_losslessly
      it 'does the list automagic for three items' do
        a[0].unparse.should eql('One -> Two')
        a[1].unparse.should eql('Three -> Four')
        a[2].unparse.should eql('Five -> Six')
      end
    end
  end

  let(:a) do
    result = produce_result
    result.stmt_list.stmts
  end
end
