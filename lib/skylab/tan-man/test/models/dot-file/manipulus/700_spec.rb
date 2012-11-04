require_relative 'test-support'

describe "#{Skylab::TanMan::Models::DotFile} Manipulus 700 series" do
  extend ::Skylab::TanMan::TestSupport::Models::DotFile::Manipulus

  using_input '705-label.dot' do
    it 'can change the value (rhs) of the label, escaping when necessary' do
      result.unparse.should eql(input_string)
      stmt = label_statement
      stmt.rhs.normalized_string.should match(/\ATangent with/)
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
    def _retrieve_label_statement
      result.stmt_list.stmts.detect do |s|
        :equals_stmt == s.class.rule && 'label' == s.lhs.normalized_string
      end
    end
    let(:label_statement) { _retrieve_label_statement }
  end

  def _can_set_and_create_the_label
    o = result
    o.get_label.should be_nil
    o.set_label! 'Zeepadeep doobop'
    o.get_label.should eql('Zeepadeep doobop')
    full = o.unparse
    full.should be_include('label="Zeepadeep doobop"')
    o.set_label! 'bipbap'
    full = o.unparse
    full.should_not be_include('Zeep')
    # the ending should not look like this: "foo}\n"
    (md = /(?<space>.)}[[:space:]]*\z/m.match(full)).should_not be_nil
    md[:space].should match(/\A[[:space:]]\z/)
    nil
  end

  using_input '710-label-prototype.dot' do
    it 'can set (AND CREATE) the label' do
      _can_set_and_create_the_label
    end
  end

  using_input '711-label-proto-shell-style.dot' do
    it 'can set (AND CREATE) the label' do
      _can_set_and_create_the_label
    end
  end
end
