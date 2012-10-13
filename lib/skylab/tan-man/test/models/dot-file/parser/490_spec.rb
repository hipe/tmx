require_relative 'test-support'
require_relative '../../../sexp/auto/test-support'


describe "#{Skylab::TanMan::Models::DotFile::Parser} 490 series" do
  extend ::Skylab::TanMan::Sexp::Auto::TestSupport
  extend ::Skylab::TanMan::Models::DotFile::Parser::TestSupport

  using_input '490-datastruct-essential.dot' do
    it 'should look kewl, unparse losslessly, semantify an edge stmt' do
      result.unparse.should eql(input_string)
      result.stmt_list.stmts.map { |x| x.class.expression }.should eql(
        [:attr_stmt, :node_stmt, :node_stmt, :node_stmt, :edge_stmt, :edge_stmt]
      )
      stmt = result.stmt_list.stmts.detect { |x| :edge_stmt == x.class.expression }
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
  using_input '699-psg.dot' do
    it 'should parse this representative graph with HTML in it' do
      (!! result).should eql(true)
      a = result.stmt_list.stmts
      a.length.should eql(26)
      stmt = a[4]
      tgt_a_list = stmt.attr_list.a_list.a_list.a_list.a_list.a_list.a_list
        # the above is fragile and ugly but we decide here to finish up this
        # html piece before we figure out how to "inferitize" the pattern #todo
      tgt_a_list.equals.id.class.expression.should eql(:id_html)
      tgt_a_list.equals.id.content_text_value.should(
        match(%r{\A<table .+</table>\z}))
    end
  end
end
