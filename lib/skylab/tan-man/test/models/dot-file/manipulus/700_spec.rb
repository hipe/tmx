require_relative '../parser/test-support'
require_relative '../../../sexp/auto/test-support'

describe "#{Skylab::TanMan::Models::DotFile} Manipulus 700 series" do
  extend ::Skylab::TanMan::Sexp::Auto::TestSupport
  extend ::Skylab::TanMan::Models::DotFile::Parser::TestSupport

  using_input '705-label.dot' do
    it 'can change the value (rhs) of the label, escaping when necessary' do
      result.unparse.should eql(input_string)
      stmt = result.stmt_list.stmts.detect do |s|
        :equals_stmt == s.class.rule && 'label' == s.lhs.string
      end
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
    it "it can remove the label and unparse"
    it "it can add a label"
  end
end
