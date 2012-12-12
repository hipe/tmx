require_relative 'test-support'

describe "#{Skylab::TanMan::Models::DotFile::Parser} 490 series" do
  extend ::Skylab::TanMan::TestSupport::Models::DotFile::Parser

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
      stmts = result.stmt_list.stmts
      stmts.length.should eql(26)
      stmt = stmts[4]
      a = stmt.attr_list.attrs.first.as.detect do |_a|
        'label' == _a.id.content_text_value
      end
      a_alt = stmt.attr_list.content.a_list.a_list.a_list.a_list.a_list.content
      a.object_id.should eql(a_alt.object_id)
      a.equals.id.class.expression.should eql(:id_html)
      a.equals.id.content_text_value.should(
        match(%r{\A<table .+</table>\z}))
    end
  end
end
