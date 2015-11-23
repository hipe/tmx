require_relative '../../test-support'

Skylab::Brazen::TestSupport.lib_( :entity ).require_common_sandbox

module Skylab::Brazen::TestSupport::Entity_Sandbox

  module MMMP

  TS_.describe "[br] entity - meta-meta-meta-properties - arity" do

    context "an arity space when sent .." do

      before :all do
        S = Home_::Entity::Meta_Meta_Meta_Properties::Arity::Space.create do
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

        it "name_symbol - ok" do
          arity.name_symbol.should eql( :zero_or_one )
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

        it "name_symbol - ok" do
          arity.name_symbol.should eql( :one_or_more )
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
end
