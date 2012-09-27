require_relative 'parser/test-support'
require_relative '../../sexp/auto/test-support'


describe "#{Skylab::TanMan::Models::DotFile::Parser}" do
  extend ::Skylab::TanMan::Sexp::Auto::TestSupport
  extend ::Skylab::TanMan::Models::DotFile::Parser::TestSupport

  context 'parsing an empty digraph' do

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
    using_input '100-hello-world.dot' do
      it 'should give the same statement object, 2 ways' do
        stmt = result.stmt_list.stmt
        a = result.stmt_list._items # stmts
        a.length.should eql(1)
        a.first.unparse.should eql("Hello->World")
        a.first.object_id.should eql(stmt.object_id)
      end
    end
    using_input '200.dot' do
      it 'can get 2 items' do
        a = result.stmt_list._items # stmts
        a.length.should eql(2)
        a.first.unparse.should eql('one->two')
        a.last.unparse.should eql('three->four')
      end
    end
  end
end
