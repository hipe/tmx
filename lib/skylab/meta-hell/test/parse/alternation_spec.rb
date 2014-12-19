require_relative 'test-support'

module Skylab::MetaHell::TestSupport::Parse::Alternation

  ::Skylab::MetaHell::TestSupport::Parse[ self ]

  include Constants

  extend TestSupport_::Quickie

  MetaHell_ = MetaHell_

  describe "[mh] Parse::Alternation__" do

    it "minimally you can call it inine with (p_a, arg)" do
      res = MetaHell_::Parse.alternation[ [
        -> ix { :a == ix and :A },
        -> ix { :b == ix and :B } ],
        :b ]

      res.should eql :B
    end
    context "may be more efficient to curry the parser in one place" do

      before :all do
        P = MetaHell_::Parse.alternation.curry[ :pool_procs, [
          -> ix { :a == ix and :A },
          -> ix { :b == ix and :B } ] ]
      end
      it "and call it in another" do
        P[ :a ].should eql :A
      end
      it "and another" do
        P[ :b ].should eql :B
        P[ :c ].should eql nil
      end
    end
    it "in the minimal case, the empty parser always results in nil" do
      p = MetaHell_::Parse.alternation.curry[ :pool_procs, [] ]

      p[ :bizzle ].should eql nil
    end
    context "maintaining parse state (artibrary extra arguments)" do

      before :all do
        P_ = MetaHell_::Parse.alternation.curry[ :pool_procs, [
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
      it "parses none" do
        P_[ Result.new, [ :will, :not, :parse ] ].should eql nil
      end
      it "parses one" do
        r = Result.new
        P_[ r, [ :one ] ].should eql true
        r.is_one.should eql true
        r.is_two.should eql nil
      end
      it "parses two" do
        r = Result.new
        P_[ r, [ :two ] ].should eql true
        r.is_one.should eql nil
        r.is_two.should eql true
      end
      it "but it won't parse two after one" do
        input_a = [ :one, :two ] ; r = Result.new
        P_[ r, input_a ].should eql true
        r.is_one.should eql true
        r.is_two.should eql nil
      end
    end
  end
end
