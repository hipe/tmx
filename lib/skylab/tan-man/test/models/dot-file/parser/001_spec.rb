require_relative 'test-support'
require_relative '../../../sexp/auto/test-support'


describe "#{Skylab::TanMan::Models::DotFile::Parser} 001 series" do
  extend ::Skylab::TanMan::Sexp::Auto::TestSupport
  extend ::Skylab::TanMan::Models::DotFile::Parser::TestSupport

  context 'parsing an empty digragph' do
    def self.it_yields_a_digraph_document_sexp(*tags)
      it 'yields a digraph document sexp', *tags do
        result.should be_sexp(:graph)
      end
    end
    context "one line no spaces" do
      input 'digraph{}'
      it_unparses_losslessly
      it_yields_a_digraph_document_sexp
    end
    context "multiple lines lots of whitespace" do
      input " \n\n \tdigraph { \t } \n "
      it_unparses_losslessly
      it_yields_a_digraph_document_sexp
    end
  end
  context 'parsing a digraph with minimal content' do
    using_input '100-hello-world.dot' do
      it_unparses_losslessly
      it 'should give the same statement object, 2 ways' do
        stmt = result.stmt_list.stmt
        a = result.stmt_list.stmts
        a.length.should eql(1)
        a.first.unparse.should eql("Hello->World")
        a.first.object_id.should eql(stmt.object_id)
      end
    end
    using_input '200.dot' do
      it_unparses_losslessly
      it 'can get 2 items' do
        a = result.stmt_list.stmts
        a.length.should eql(2)
        a.first.unparse.should eql('one->two')
        a.last.unparse.should eql('three->four')
      end
    end
    using_input '410-node-with-dbl-quotes.dot' do
      it 'unparses losslessly (custom)' do
        result.stmt_list.stmt.unparse.should eql('"node0"')
        result.unparse.should eql(input_string)
      end
      it 'parses double quoted node ID\'s correctly' do
        node_stmt = result.stmt_list.stmts.first
        node_stmt.class.rule.should eql(:node_stmt)
        node_stmt.node_id.id.content_text_value.should eql('node0')
      end
    end
    using_input '480-bughunt-reduction.dot' do
      it_unparses_losslessly
      it 'works' do
        stmts = result.stmt_list.stmts
        a_list = stmts.last.attr_list.a_list
        a_list.id.content_text_value.should eql('shape')
        a_list.equals.id.content_text_value.should eql('record')
      end
    end
  end
end
