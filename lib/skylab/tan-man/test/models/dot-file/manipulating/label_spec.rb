require_relative 'label/test-support'

module Skylab::TanMan::TestSupport::Models::DotFile::Manipulating::Label

  describe "[tm] TanMan_::Models::DotFile /manipulating/labels", wip: true do

    extend TS_

    using_input '3.0-with-existing-label.dot' do

      it 'can change the value (rhs) of the label, escaping when necessary' do
        result.unparse.should eql( input_string )

        stmt = label_statement
        stmt.rhs.normalized_string.should match( /\ATangent with/ )

        stmt.rhs = "zeep"
        stmt.unparse.should eql( 'label=zeep' )

        stmt.rhs = 'zeep zoop'
        stmt.unparse.should eql( 'label="zeep zoop"' ) # look! smart quoting

        stmt.rhs = '<<b>bold</b>>'
        stmt.unparse.should eql( 'label=<<b>bold</b>>' )

        stmt.rhs = '"one"'
        stmt.unparse.should eql( 'label="one"' )

        stmt.rhs = ''
        stmt.unparse.should eql( 'label=""' )
      end


      it 'can remove the label' do
        removed = result.stmt_list._remove_item label_statement
        pn = normalized_input_pathname.dirname.join '1.0-with-no-label.dot'
        exp = pn.read
        result.unparse.should eql( exp )
        removed.unparse.should eql(
          "label=\"Tangent with the C Programming Language\"")
        _retrieve_label_statement.should eql( nil )
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
      o.get_label.nil?.should eql( true )
      o.set_label 'Zeepadeep doobop'
      o.get_label.should eql('Zeepadeep doobop')
      full = o.unparse
      full.include?( 'label="Zeepadeep doobop"' ).should eql(true)
      o.set_label 'bipbap'
      full = o.unparse
      full.include?( 'Zeep' ).should eql(false)
      # the ending should not look like this: "foo}\n"
      (md = /(?<space>.)}[[:space:]]*\z/m.match(full))
      ( !!md ).should eql( true ) # egads sorry rspec
      md[:space].should match( /\A[[:space:]]\z/ )
      nil
    end



    using_input(
      '5.0-with-example-label-stmt-in-c-style-comments-and-empty-graph.dot' ) do

      it 'can set (AND CREATE) the label' do
        _can_set_and_create_the_label
      end
    end



    using_input(
      '5.5-with-example-label-stmt-in-shell-style-comments-and-empty-graph.dot'
    ) do

      it 'can set (AND CREATE) the label' do
        _can_set_and_create_the_label
      end
    end
  end
end
