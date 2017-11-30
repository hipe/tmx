require_relative '../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] sexp prototype", wip: true do

    TS_[ self ]
    use :sexp_prototype

  # <-

  using_grammar '70-38-simplo' do

    using_input_string EMPTY_S_, 'totally empty input string' do

      it 'has no list controller' do
        expect( result.node_list ).to be_nil
      end
    end

    using_input_string "\n\t  ", 'whitespace only input string' do

      it 'has no list controller' do
        expect( result.node_list ).to be_nil
      end
    end

    using_input_string 'fap;fip', 'two element input string' do

      it 'enumerates' do
        result.node_list.nodes
        expect( result.node_list.nodes ).to eql [ 'fap', 'fip' ]
      end
    end

    using_input 'invalid-prototype' do

      it 'raises a runmun error at parse time' do

        _exception_class = subject::Invalid_Prototype
        begin
          result
        rescue _exception_class => e
        end

        _head = 'when parsing your "node_list" prototype embedded in a comment: Expected one of'
        e.message.include? _head or fail
      end
    end

    using_input 'two-element-prototype' do

      it 'appends and inserts valid string items - PARTIALLY PENDING' do

        o = result.node_list

        x = o.append_item_via_string_ 'faeioup'
        expect( x.object_id ).to eql o.object_id
        expect( o.unparse ).to eql 'faeioup'  # no separator here
        lines = result.unparse.split NEWLINE_
        expect( lines.length ).to eql 2
        expect( lines.last ).to eql 'faeioup'

        x = o.append_item_via_string_ 'fooooop'
        expect( ( x.object_id == o.object_id ) ).to eql false
        expect( o.unparse ).to eql 'faeioup ;  fooooop'  # exactly what u asked for

        x = o.append_item_via_string_ 'fuuup'
        expect( ( x.object_id == o.object_id ) ).to eql false

        exp = 'faeioup ;  fooooop ;  fuuup'
        expect( o.unparse ).to eql exp
        expect( @result.unparse.split( NEWLINE_ ).last ).to eql exp

        o.insert_item_before_item_string_ 'faeup', 'fooooop'
        expect( o.unparse ).to eql 'faeioup ;  faeup ;  fooooop ;  fuuup'
      end

      it "append an invalid node - raises" do
        expect( -> do
          result.node_list.append_item_via_string_ 'fzzzp'
        end ).to raise_error Home_::Sexp_::Auto::Parse_Failure
      end
    end
  end

  using_grammar '70-78-with-prototype' do

    using_input_string 'beginning ending', 'zero' do

      it 'has no list controller' do
        expect( result.node_list ).to be_nil
      end
    end

    using_input_string 'beginning feep ending', 'one' do

      it 'enumerates' do
        expect( unparses ).to eql [ 'feep' ]
      end
    end

    using_input_string 'beginning fap;fep;fip ending', 'three' do

      it 'enumerates' do
        expect( unparses ).to eql [ 'fap', 'fep', 'fip' ]
      end
    end

    using_input 'primordial' do

      it "append valid strings - separator semantics because prototype" do

        o = result.node_list
        expect( o.nodes ).to eql EMPTY_A_

        x = o.append_item_via_string_ 'fiiiiip;'
        expect( x.object_id ).to eql o.object_id
        expect( o.unparse ).to eql "fiiiiip\n"

        o.append_item_via_string_ 'fap;'
        expect( o.unparse ).to eql "fiiiiip;\nfap\n"
      end

      it 'raises an exception if you try to append an invalid string' do

        expect( -> do
          result.node_list.append_item_via_string_ 'fzzzp'
        end ).to raise_error Home_::Sexp_::Auto::Parse_Failure
      end
    end
  end

  # ->

    def unparses
      result.node_list.nodes.map( & :unparse )
    end

    def subject
      Home_::Sexp_::Prototype
    end
  end
end
