require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] operations - dot file - update label" do

    TS_[ self ]
    use :models_dot_file

    memoize :fixtures_path_ do
      ::File.join TS_.dir_path, 'fixture-dot-files-for-label'
    end

    using_input '3.0-with-existing-label.dot' do

      it 'can change the value (rhs) of the label, escaping when necessary' do

        unparse_losslessly

        stmt = _retrieve_label_statement
        stmt.rhs.normal_content_string_ =~ /\ATangent with/ || fail

        stmt.rhs = "zeep"
        expect( stmt.unparse ).to eql 'label=zeep'

        stmt.rhs = 'zeep zoop'
        expect( stmt.unparse ).to eql 'label="zeep zoop"' # look! smart quoting

        stmt.rhs = '<<b>bold</b>>'
        expect( stmt.unparse ).to eql 'label=<<b>bold</b>>'

        stmt.rhs = '"one"'
        expect( stmt.unparse ).to eql 'label="one"'

        stmt.rhs = ''
        expect( stmt.unparse ).to eql 'label=""'
      end

      it 'can remove the label' do

        removed = result.stmt_list.remove_item_ _retrieve_label_statement

        _path = ::File.join fixtures_path_, '1.0-with-no-label.dot'

        _expected_s = read_file_ _path

        expect( @result.unparse ).to eql _expected_s

        expect( removed.unparse ).to eql(
          "label=\"Tangent with the C Programming Language\"")

        expect( _retrieve_label_statement ).to be_nil
      end

      _LABEL = 'label'

      define_method :_retrieve_label_statement do
        result.stmt_list.stmts.detect do |sx|
          :equals_stmt == sx.class.rule_symbol && _LABEL == sx.lhs.normal_content_string_
        end
      end
    end

    using_input '5.0-with-example-label-stmt-in-c-style-comments-and-empty-graph.dot' do

      it 'can set (AND CREATE) the label' do
        _can_set_and_create_the_label
      end
    end

    using_input '5.5-with-example-label-stmt-in-shell-style-comments-and-empty-graph.dot' do

      it 'can set (AND CREATE) the label' do
        _can_set_and_create_the_label
      end
    end

    def _can_set_and_create_the_label
      o = result
      expect( o.get_label_.nil? ).to eql true
      o.set_label 'Zeepadeep doobop'
      expect( o.get_label_ ).to eql 'Zeepadeep doobop'
      full = o.unparse
      expect( full.include?( 'label="Zeepadeep doobop"' ) ).to eql true
      o.set_label 'bipbap'
      full = o.unparse
      expect( full.include?( 'Zeep' ) ).to eql false
      # the ending should not look like this: "foo}\n"
      (md = /(?<space>.)}[[:space:]]*\z/m.match(full))
      expect( ( !!md ) ).to eql true # egads sorry rspec
      expect( md[:space] ).to match( /\A[[:space:]]\z/ )
      nil
    end
  end
end
