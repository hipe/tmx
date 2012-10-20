require_relative '../parser/test-support'
require_relative '../../../sexp/auto/test-support'

describe "#{Skylab::TanMan::Models::DotFile} Manipulus 700 series" do
  extend ::Skylab::TanMan::Sexp::Auto::TestSupport
  extend ::Skylab::TanMan::Models::DotFile::Parser::TestSupport

  using_input '705-label.dot' do
    it 'can change the value (rhs) of the label, escaping when necessary' do
      result.unparse.should eql(input_string)
      stmt = label_statement
      stmt.rhs.string.should match(/\ATangent with/)
      stmt.rhs = "zeep"
      stmt.unparse.should eql('label=zeep')
      stmt.rhs = 'zeep zoop'
      stmt.unparse.should eql('label="zeep zoop"')
      stmt.rhs = '<<b>bold</b>>'
      stmt.unparse.should eql('label=<<b>bold</b>>')
      stmt.rhs = '"one"'
      stmt.unparse.should eql('label="one"')
      stmt.rhs = ''
      stmt.unparse.should eql('label=""')
    end
    it 'can remove the label' do
      removed = result.stmt_list._remove!(label_statement)
      result.unparse.should eql(input_pathname.join('../704-lableless.dot').read)
      removed.unparse.should eql(
        "label=\"Tangent with the C Programming Language\"")
      _retrieve_label_statement.should eql(nil)
    end
    # it "it can add a label"
    def _retrieve_label_statement
      result.stmt_list.stmts.detect do |s|
        :equals_stmt == s.class.rule && 'label' == s.lhs.string
      end
    end
    let(:label_statement) { _retrieve_label_statement }
  end
end
