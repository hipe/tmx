require_relative 'prototype/test-support'

module Skylab::TanMan::TestSupport::Sexp::Prototype

  describe "[tm] Sexp::Prototype will be awesome" do

    extend TS_  # #borrow:one

  using_grammar '70-38-simplo' do

    using_input_string EMPTY_S_, 'totally empty input string' do

      it 'has no list controller', f: true do
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
        ->{ result }.should raise_error(/when parsing .+prototype/)
      end
    end

    using_input 'two-element-prototype' do
      it 'appends and inserts valid string items - PARTIALLY PENDING' do
        o = result.node_list
        r = o._append! 'faeioup'
        o.object_id.should eql( r.object_id )
        o.unparse.should eql( 'faeioup' ) # no seaprator here
        lines = result.unparse.split NEWLINE_
        lines.length.should eql( 2 )
        lines.last.should eql( 'faeioup' )
        r = o._append! 'fooooop'
        ( r.object_id == o.object_id ).should eql( false )
        o.unparse.should eql( 'faeioup ;  fooooop' ) # exactly what u asked for
        r2 = o._append! 'fuuup'
        ( r2.object_id == r.object_id ).should eql( false )
        exp = 'faeioup ;  fooooop ;  fuuup'
        o.unparse.should eql( exp )
        result.unparse.split( "\n" ).last.should eql( exp )
        if false
        o._insert_item_before_item 'faeup', 'fooooop'
        o.unparse.should eql( 'faeioup ;  faeup ;  fooooop ;  fuuup' )
        end
      end

      it 'appends an invalid string as an item' do
        result.node_list._append!('fzzzp')
        result.node_list.unparse.should eql('fzzzp')
      end
    end
  end

  using_grammar '70-75-with-prototype' do

    using_input_string 'beginning ending', 'zero' do

      it 'has no list controller' do
        result.node_list.should be_nil
      end
    end

    using_input_string 'beginning feep ending', 'one' do

      it('enumerates') { unparses.should eql(['feep']) }
    end

    using_input_string 'beginning fap;fep;fip ending', 'three' do

      it('enumerates') { unparses.should eql(['fap', 'fep', 'fip']) }
    end

    using_input 'primordial' do

      it 'appends a valid string as an item - BORKED - where are semis?' do
        o = result.node_list
        o.nil?.should eql( false )
        o.nodes.should eql( [] )
        r = o._append! 'fiiiiip'
        r.object_id.should eql(o.object_id)
        o.unparse.should eql( "fiiiiip;\n" )
        o._append! 'fap'
        o.unparse.should eql( "fiiiiip;\nfap\n" ) # look what it did!
      end

      it 'raises an exception if you try to append an invalid string' do
        ->{ result.node_list._append!('fzzzp') }.should raise_error(
          /failed to parse item to insert/)
      end
    end

    # --*--
    def unparses
      result.node_list.nodes.map(&:unparse)
    end
  end
end
end # a hiccup in indentation for Quickie
