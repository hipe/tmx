require_relative 'test-support'

module Skylab::MetaHell::TestSupport::FUN::Parse::From_Set

  ::Skylab::MetaHell::TestSupport::FUN::Parse[ self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::MetaHell::FUN::Parse::From_Set" do
    context "more flexible, powerful and complex pool-based deterministic parsing" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          P = MetaHell::FUN.parse_from_set.curry[ :pool_procs, [ ] ]
        end
      end
      it "a parser with no nodes in it will always report 'no parse' and 'spent'" do
        Sandbox_1.with self
        module Sandbox_1
          P[ argv = [] ].should eql( [ false, true ] )
          argv.should eql( [] )
        end
      end
      it "even if the input is rando calrissian" do
        Sandbox_1.with self
        module Sandbox_1
          P[ argv = :hi_mom ].should eql( [ false, true ] )
          argv.should eql( :hi_mom )
        end
      end
    end
    context "with parser with one node that reports it always matches & always spends" do
      Sandbox_2 = Sandboxer.spawn
      it "it always reports the same as a final result" do
        Sandbox_2.with self
        module Sandbox_2
          P = MetaHell::FUN.parse_from_set.curry[ :pool_procs, [
           -> _input {  [ true, true ] }
          ]]

          P[ :whatever ].should eql( [ true, true ] )
        end
      end
    end
    context "with a parser with one node that reports it never matches & always spends" do
      Sandbox_3 = Sandboxer.spawn
      it "it always reports the same as a final result" do
        Sandbox_3.with self
        module Sandbox_3
          P = MetaHell::FUN.parse_from_set.curry[ :pool_procs, [
            -> _input {  [ false, true ] }
          ]]

          P[ :whatever ].should eql( [ false, true ] )
        end
      end
    end
    context "with a parser that parses any digits & any of 2 keywords (only once each)" do
      Sandbox_4 = Sandboxer.spawn
      before :all do
        Sandbox_4.with self
        module Sandbox_4
          keyword = -> kw do
            -> memo, argv do
              if argv.length.nonzero? and kw == argv.first
                argv.shift
                memo[ kw.intern ] = true
                [ true, true ]
              end
            end
          end

          P = MetaHell::FUN.parse_from_set.curry[ :pool_procs, [
            keyword[ 'foo' ],
            keyword[ 'bar' ],
            -> memo, argv do
              if argv.length.nonzero? and /\A\d+\z/ =~ argv.first
                ( memo[:nums] ||= [ ] ) << argv.shift.to_i
                [ true, false ]
              end
            end
          ]]
        end
      end
      it "it will do nothing to nothing" do
        Sandbox_4.with self
        module Sandbox_4
          P[ ( memo = { } ), [] ].should eql( [ false, false ] )
          memo.length.should eql( 0 )
        end
      end
      it "parses one digit" do
        Sandbox_4.with self
        module Sandbox_4
          P[ ( memo = { } ), argv = [ '1' ] ].should eql( [ true, false ] )
          argv.length.should eql( 0 )
          memo[ :nums ].should eql( [ 1 ] )
        end
      end
      it "parses two digits" do
        Sandbox_4.with self
        module Sandbox_4
          P[ ( memo = { } ), argv = [ '2', '3' ] ].should eql( [ true, false ] )
          argv.length.should eql( 0 )
          memo[ :nums ].should eql( [ 2, 3 ] )
        end
      end
      it "parses one keyword" do
        Sandbox_4.with self
        module Sandbox_4
          P[ ( memo = { } ), argv = [ 'bar' ] ].should eql( [ true, false ] )
          argv.length.should eql( 0 )
          memo[ :bar ].should eql( true )
        end
      end
      it "parses two keywords" do
        Sandbox_4.with self
        module Sandbox_4
          P[ ( memo = { } ), argv = [ 'bar', 'foo' ] ].should eql( [ true, false ] )
          argv.length.should eql( 0 )
          memo[ :bar ].should eql( true )
          memo[ :foo ].should eql( true )
        end
      end
      it "will not parse multiple of same keyword" do
        Sandbox_4.with self
        module Sandbox_4
          P[ ( memo = { } ), argv = [ 'foo', 'foo' ] ].should eql( [ true, false ] )
          argv.should eql( [ 'foo' ] )
          memo[ :foo ].should eql( true )
        end
      end
      it "will stop at first non-parsable" do
        Sandbox_4.with self
        module Sandbox_4
          argv = [ '1', 'foo', '2', 'biz', 'bar' ]
          P[ ( memo = { } ), argv ].should eql( [ true, false ] )
          argv.should eql( [ 'biz', 'bar' ] )
          memo[ :nums ].should eql( [ 1, 2 ] )
          memo[ :foo  ].should eql( true )
          memo[ :bar  ].should eql( nil )
        end
      end
    end
  end
end
