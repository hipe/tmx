require_relative '../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] sexp prototype", wip: true do

    TS_[ self ]
    use :sexp_prototype

  # <-

  using_grammar '70-38-simplo' do

    using_input_string EMPTY_S_, 'totally empty input string' do

      it 'has no list controller' do
        result.node_list.should be_nil
      end
    end

    using_input_string "\n\t  ", 'whitespace only input string' do

      it 'has no list controller' do
        result.node_list.should be_nil
      end
    end

    using_input_string 'fap;fip', 'two element input string' do

      it 'enumerates' do
        result.node_list.nodes
        result.node_list.nodes.should eql(['fap', 'fip'])
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
        x.object_id.should eql o.object_id
        o.unparse.should eql 'faeioup'  # no separator here
        lines = result.unparse.split NEWLINE_
        lines.length.should eql 2
        lines.last.should eql 'faeioup'

        x = o.append_item_via_string_ 'fooooop'
        ( x.object_id == o.object_id ).should eql false
        o.unparse.should eql 'faeioup ;  fooooop'  # exactly what u asked for

        x = o.append_item_via_string_ 'fuuup'
        ( x.object_id == o.object_id ).should eql false

        exp = 'faeioup ;  fooooop ;  fuuup'
        o.unparse.should eql exp
        @result.unparse.split( NEWLINE_ ).last.should eql exp

        o.insert_item_before_item_string_ 'faeup', 'fooooop'
        o.unparse.should eql 'faeioup ;  faeup ;  fooooop ;  fuuup'
      end

      it "append an invalid node - raises" do
        -> do
          result.node_list.append_item_via_string_ 'fzzzp'
        end.should raise_error Home_::Sexp_::Auto::Parse_Failure
      end
    end
  end

  using_grammar '70-78-with-prototype' do

    using_input_string 'beginning ending', 'zero' do

      it 'has no list controller' do
        result.node_list.should be_nil
      end
    end

    using_input_string 'beginning feep ending', 'one' do

      it 'enumerates' do
        unparses.should eql [ 'feep' ]
      end
    end

    using_input_string 'beginning fap;fep;fip ending', 'three' do

      it 'enumerates' do
        unparses.should eql [ 'fap', 'fep', 'fip' ]
      end
    end

    using_input 'primordial' do

      it "append valid strings - separator semantics because prototype" do

        o = result.node_list
        o.nodes.should eql EMPTY_A_

        x = o.append_item_via_string_ 'fiiiiip;'
        x.object_id.should eql o.object_id
        o.unparse.should eql "fiiiiip\n"

        o.append_item_via_string_ 'fap;'
        o.unparse.should eql "fiiiiip;\nfap\n"
      end

      it 'raises an exception if you try to append an invalid string' do

        -> do
          result.node_list.append_item_via_string_ 'fzzzp'
        end.should raise_error Home_::Sexp_::Auto::Parse_Failure
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
