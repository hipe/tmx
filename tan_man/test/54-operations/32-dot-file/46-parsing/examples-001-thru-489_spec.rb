require_relative '../../../test-support'

module Skylab::TanMan::TestSupport

describe "[tm] operations - dot-file parsing - examples 001 to 489" do

  TS_[ self ]
  use :models_dot_file_parsing

  context "parsing an empty digraph" do

    context "one line no spaces" do

      against_string 'digraph{}'

      it "unparses losslessly" do
        unparse_losslessly
      end

      it "produces a digraph document sexp" do
        want_digraph_document_sexp
      end
    end

    context "multiple lines lots of whitespace" do

      against_string " \n\n \tdigraph { \t } \n "

      it "unparses losslessly" do
        unparse_losslessly
      end

      it "produces a digraph document sexp" do
        want_digraph_document_sexp
      end
    end
  end

  context 'parsing a digraph with minimal content' do

    context "against a two-node \"hello world\" graph (input #100)" do

      against_file '100-hello-world.dot'

      it "unparses losslessly" do
        unparse_losslessly
      end

      it 'should give the same statement object, 2 ways' do
        stmt = result.stmt_list.stmt
        a = result.stmt_list.stmts
        expect( a.length ).to eql 1
        expect( a.first.unparse ).to eql "Hello->World"
        expect( a.first.object_id ).to eql stmt.object_id
      end
    end

    context "against a four-node, two-edge graph (input #200)" do

      against_file '200.dot'

      it "unparses losslessly" do
        unparse_losslessly
      end

      it 'can get 2 items' do
        a = result.stmt_list.stmts
        expect( a.length ).to eql 2
        expect( a.first.unparse ).to eql 'one->two'
        expect( a.last.unparse ).to eql 'three->four'
      end
    end

    context "parsing a digraph with nodes with double quotes (input #400)" do

      against_file '410-node-with-dbl-quotes.dot'

      it 'unparses losslessly (custom)' do
        expect( result.stmt_list.stmt.unparse ).to eql '"node0"'
        expect( result.unparse ).to eql some_input_string
      end

      it 'parses double quoted node ID\'s correctly' do
        node_stmt = result.stmt_list.stmts.first
        node_stmt.class.rule_symbol == :node_stmt || fail
        expect( node_stmt[ :node_id ].id.content_text_value ).to eql 'node0'
      end
    end

    context "(buthunt reduction, input #480)" do

      against_file '480-bughunt-reduction.dot'

      it "unparses losslessly" do
        unparse_losslessly
      end

      it 'works' do
        stmts = result.stmt_list.stmts
        a_list = stmts.last.attr_list.content
        expect( a_list.content.id.content_text_value ).to eql 'shape'
        expect( a_list.content.equals.id.content_text_value ).to eql 'record'
      end
    end
  end
end
end
