require_relative 'test-support'
require_relative '../../../sexp/auto/test-support'


describe "#{Skylab::TanMan::Models::DotFile::Parser} 490 series" do
  extend ::Skylab::TanMan::Sexp::Auto::TestSupport
  extend ::Skylab::TanMan::Models::DotFile::Parser::TestSupport

  using_input '490-datastruct-essential.dot' do
    it 'should look kewl, unparse losslessly, semantify an edge stmt' do
      result.unparse.should eql(input_string)
      result.stmt_list.stmts.map { |x| x.class.nt_name }.should eql(
        [:attr_stmt, :node_stmt, :node_stmt, :node_stmt, :edge_stmt, :edge_stmt]
      )
      stmt = result.stmt_list.stmts.detect { |x| :edge_stmt == x.class.nt_name }
      stmt.agent.id.content_text_value.should eql('node0')
      stmt.edge_rhs.edgeop.should eql('->')
      stmt.edge_rhs.recipient.id.content_text_value.should eql('node1')
    end
  end
  using_input '500-datastruct.dot' do
    it 'should parse and loslessly unparse this representative example' do
      (!! result).should eql(true)
      result.unparse.should eql(input_string)
    end
  end
end
