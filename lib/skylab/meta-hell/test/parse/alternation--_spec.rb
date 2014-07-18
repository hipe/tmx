require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse::Alternation__

  ::Skylab::MetaHell::TestSupport::Parse[ self ]

  include CONSTANTS

  MetaHell = ::Skylab::MetaHell

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "[mh] Parse::Alternation__" do
    context "a normative example" do
      Sandbox_1 = Sandboxer.spawn
      it "like so" do
        Sandbox_1.with self
        module Sandbox_1
          res = MetaHell::Parse.alternation[ [
            -> ix { :a == ix and :A },
            -> ix { :b == ix and :B } ],
            :b ]

          res.should eql( :B )
        end
      end
    end
    context "it may be useful to curry your parser in one place" do
      Sandbox_2 = Sandboxer.spawn
      before :all do
        Sandbox_2.with self
        module Sandbox_2
          P = MetaHell::Parse.alternation.curry[ :pool_procs, [
            -> ix { :a == ix and :A },
            -> ix { :b == ix and :B } ] ]
        end
      end
      it "and then use it in another" do
        Sandbox_2.with self
        module Sandbox_2
          P[ :a ].should eql( :A )
        end
      end
      it "and another" do
        Sandbox_2.with self
        module Sandbox_2
          P[ :b ].should eql( :B )
          P[ :c ].should eql( nil )
        end
      end
    end
    context "the minimal case" do
      Sandbox_3 = Sandboxer.spawn
      it "the empty parser always result in nil" do
        Sandbox_3.with self
        module Sandbox_3
          P = MetaHell::Parse.alternation.curry[ :pool_procs, [] ]

          P[ :bizzle ].should eql( nil )
        end
      end
    end
    context "maintaining parse state (artibrary extra arguments)" do
      Sandbox_4 = Sandboxer.spawn
      before :all do
        Sandbox_4.with self
        module Sandbox_4
          P = MetaHell::Parse.alternation.curry[ :pool_procs, [
            -> output_x, input_x do
              if :one == input_x.first
                input_x.shift
                output_x[ :is_one ] = true
                true
              end
            end,
            -> output_x, input_x do
              if :two == input_x.first
                input_x.shift
                output_x[ :is_two ] = true
                true
              end
            end ] ]

          Result = ::Struct.new :is_one, :is_two
        end
      end
      it "like so" do
        Sandbox_4.with self
        module Sandbox_4
          P[ Result.new, [ :will, :not, :parse ] ].should eql( nil )
        end
      end
      it "it parses one" do
        Sandbox_4.with self
        module Sandbox_4
          r = Result.new
          P[ r, [ :one ] ].should eql( true )
          r.is_one.should eql( true )
          r.is_two.should eql( nil )
        end
      end
      it "it parses two" do
        Sandbox_4.with self
        module Sandbox_4
          r = Result.new
          P[ r, [ :two ] ].should eql( true )
          r.is_one.should eql( nil )
          r.is_two.should eql( true )
        end
      end
      it "but it won't parse two after one" do
        Sandbox_4.with self
        module Sandbox_4
          input_a = [ :one, :two ] ; r = Result.new
          P[ r, input_a ].should eql( true )
          r.is_one.should eql( true )
          r.is_two.should eql( nil )
        end
      end
    end
  end
end
