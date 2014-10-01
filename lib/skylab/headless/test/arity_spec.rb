require_relative 'test-support'

module Skylab::Headless::TestSupport::Arity

  ::Skylab::Headless::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Headless_ = Headless_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  describe "a Skylab::Headless::Arity" do

    context "Space when sent" do

      before :all do
        S = Headless_::Arity::Space.create do
          self::ZERO_OR_ONE = new 0, 1
          self::ONE_OR_MORE = new 1, nil
        end
      end

      it "members - duped array of members" do
        S.members.should eql(( a = [ :zero_or_one, :one_or_more ] ))
        ( S.members.object_id == a.object_id ).should eql( false )
      end

      it "aref ([]) - with ok name" do
        S[ :zero_or_one ].should eql( S::ZERO_OR_ONE )
      end

      it "aref ([]) - with bad name - nil" do
        S[ :not_there ].should eql( nil )
      end

      it "fetch - with good name" do
        S.fetch( :one_or_more ).should eql( S::ONE_OR_MORE )
      end

      it "fetch - bad name and default" do
        S.fetch( :no ) { :x }.should eql( :x )
      end

      it "fetch - with bad name and no default" do
        -> do
          S.fetch( :nope )
        end.should raise_error( ::KeyError, /key not found: :nope/ )
      end

      context "the zero or one arity when sent" do

        let :arity do
          S.fetch :zero_or_one
        end

        it "local_normal_name - ok" do
          arity.local_normal_name.should eql( :zero_or_one )
        end

        it "includes_zero - yes" do
          arity.includes_zero.should eql( true )
        end

        it "is_polyadic - no" do
          arity.is_polyadic.should eql( false )
        end

        it "include?( 0 ) - yes" do
          arity.include?( 0 ).should eql( true )
        end

        it "include?( 1 ) - yes" do
          arity.include?( 1 ).should eql( true )
        end

        it "include?( 2 ) - no" do
          arity.include?( 2 ).should eql( false )
        end
      end

      context "the one or more arity when sent" do

        let :arity do
          S.fetch :one_or_more
        end

        it "local_normal_name - ok" do
          arity.local_normal_name.should eql( :one_or_more )
        end

        it "includes_zero - no" do
          arity.includes_zero.should eql( false )
        end

        it "is_polyadic - yes" do
          arity.is_polyadic.should eql( true )
        end

        it "include?( 0 ) - false" do
          arity.include?( 0 ).should eql( false )
        end

        it "include?( 1 ) - yes" do
          arity.include?( 1 ).should eql( true )
        end

        it "include?( 2 ) - yes" do
          arity.include?( 2 ).should eql( true )
        end
      end
    end
  end
end
