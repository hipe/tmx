require_relative '../../test-support'

module Skylab::MetaHell::TestSupport::Parse::Via_Set

  ::Skylab::MetaHell::TestSupport::Parse[ self ]

  include Constants

  extend TestSupport_::Quickie

  MetaHell_ = MetaHell_

  describe "[mh] Parse::Via_Set__", wip: true do

    context "with one such parser build from an empty set of parsers" do

      before :all do
        None = Subject_[].via_set.curry_with :pool_procs, []
      end
      it "a parser with no nodes in it will always report 'no parse' and 'spent'" do
        None[ argv = [] ].should eql [ false, true ]
        argv.should eql []
      end
      it "even if the input is rando calrissian" do
        None[ argv = :hi_mom ].should eql [ false, true ]
        argv.should eql :hi_mom
      end
    end
    context "with parser with one node that reports it always matches & always spends" do

      before :all do
        One = Subject_[].via_set.curry_with( :pool_procs, [
         -> _input {  [ true, true ] }
        ] )
      end
      it "always reports the same as a final result" do
        One[ :whatever ].should eql [ true, true ]
      end
    end
    context "with a parser with one node that reports it never matches & always spends" do

      before :all do
        Spendless = Subject_[].via_set.curry_with( :pool_procs, [
          -> _input {  [ false, true ] }
        ] )
      end
      it "always reports the same as a final result" do
        Spendless[ :whatever ].should eql [ false, true ]
      end
    end
    context "a parser that parses any digits & any of 2 keywords (only once each)" do

      before :all do
        keyword = -> kw do
          -> memo, argv do
            if argv.length.nonzero? and kw == argv.first
              argv.shift
              memo[ kw.intern ] = true
              [ true, true ]
            end
          end
        end

        Digits = Subject_[].via_set.curry_with :pool_procs, [
          keyword[ 'foo' ],
          keyword[ 'bar' ],
          -> memo, argv do
            if argv.length.nonzero? and /\A\d+\z/ =~ argv.first
              ( memo[:nums] ||= [ ] ) << argv.shift.to_i
              [ true, false ]
            end
          end
        ]
      end
      it "does nothing with nothing" do
        Digits[ ( memo = {} ), [] ].should eql [ false, false ]
        memo.length.should eql 0
      end
      it "parses one digit" do
        Digits[ ( memo = { } ), argv = [ '1' ] ].should eql [ true, false ]
        argv.length.should eql 0
        memo[ :nums ].should eql [ 1 ]
      end
      it "parses two digits" do
        Digits[ ( memo = { } ), argv = [ '2', '3' ] ].should eql [ true, false ]
        argv.length.should eql 0
        memo[ :nums ].should eql [ 2, 3 ]
      end
      it "parses one keyword" do
        Digits[ ( memo = { } ), argv = [ 'bar' ] ].should eql [ true, false ]
        argv.length.should eql 0
        memo[ :bar ].should eql true
      end
      it "parses two keywords" do
        Digits[ ( memo = { } ), argv = [ 'bar', 'foo' ] ].should eql [ true, false ]
        argv.length.should eql 0
        memo[ :bar ].should eql true
        memo[ :foo ].should eql true
      end
      it "will not parse multiple of same keyword" do
        Digits[ ( memo = { } ), argv = [ 'foo', 'foo' ] ].should eql [ true, false ]
        argv.should eql [ 'foo' ]
        memo[ :foo ].should eql true
      end
      it "will stop at first non-parsable" do
        argv = [ '1', 'foo', '2', 'biz', 'bar' ]
        Digits[ ( memo = { } ), argv ].should eql [ true, false ]
        argv.should eql [ 'biz', 'bar' ]
        memo[ :nums ].should eql [ 1, 2 ]
        memo[ :foo  ].should eql true
        memo[ :bar  ].should eql nil
      end
    end
  end
end
