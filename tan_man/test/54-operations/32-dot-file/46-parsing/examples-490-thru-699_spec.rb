require_relative '../../../test-support'

module Skylab::TanMan::TestSupport

describe "[tm] operations - dot-file parsing - examples 490 to 699" do

  TS_[ self ]
  use :models_dot_file_parsing

  context "using `rankdir=LR` and pipes in labels (input #490)" do

    against_file '490-datastruct-essential.dot'

    it 'should look kewl, unparse losslessly, semantify an edge stmt' do

      unparse_losslessly
      x = @result

      _wat = x.stmt_list.stmts.map do |sx|
        sx.class.expression_symbol
      end

      _wat == (
        [:attr_stmt, :node_stmt, :node_stmt, :node_stmt, :edge_stmt, :edge_stmt]
      ) || fail

      stmt = x.stmt_list.stmts.detect do |sx|
        :edge_stmt == sx.class.expression_symbol
      end

      stmt.agent.id.content_text_value == "node0" || fail
      stmt.edge_rhs.edgeop == "->" || fail
      stmt.edge_rhs.recipient.id.content_text_value == "node1" || fail
    end
  end

  context "a full, non-minimal graph-viz example, like above (input #500)" do

    against_file '500-datastruct.dot'

    it 'should parse and loslessly unparse this representative example' do
      unparse_losslessly
    end
  end

  context "a full, non-minimal graph-viz examle with HTML in it (input #699)" do

    against_file '699-psg.dot'

    it 'should parse this representative graph with HTML in it' do

      x = result
      stmts = x.stmt_list.stmts
      stmts.length.should eql(26)
      stmt = stmts[4]
      a = stmt.attr_list.attrs.first.as.detect do |_a|
        'label' == _a.id.content_text_value
      end
      a_alt = stmt.attr_list.content.a_list.a_list.a_list.a_list.a_list.content
      a.object_id.should eql(a_alt.object_id)
      a.equals.id.class.expression_symbol == :id_html || fail
      a.equals.id.content_text_value.should(
        match(%r{\A<table .+</table>\z}))
    end
  end
end
end
