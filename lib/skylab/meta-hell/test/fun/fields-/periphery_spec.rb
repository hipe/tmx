require_relative 'test-support'

module Skylab::MetaHell::TestSupport::FUN::Fields_

  ::Skylab::MetaHell::TestSupport::FUN[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  Subject = MetaHell::FUN::Fields_::Contoured_

  describe "[mh] fun fields periphery" do

    it "whines on weirdness" do
      -> do
        module Foo
          Subject[ self, :weirdness ]
        end
      end.should raise_error( ::KeyError, /key not found: :weirdness/ )
    end

    it "makes a non-memoized proc" do
      class Bar
        Subject[ self, :proc, :jimmy ]
      end
      b = Bar.new( :jimmy, -> { 'whales' } )
      (( s1 = b.jimmy )).should eql( 'whales' )
      (( s2 = b.jimmy )).should eql( 'whales' )
      ( s1.object_id == s2.object_id ).should eql( false )
    end

    it "makes a memoizing proc" do
      class Baz
        Subject[ self, :memoized, :proc, :jimmy ]
      end
      b = Baz.new( :jimmy, -> { 'whales' } )
      (( s1 = b.jimmy )).should eql( 'whales' )
      (( s2 = b.jimmy )).should eql( 'whales' )
      ( s1.object_id == s2.object_id ).should eql( true )
    end

    it "one memoized and one not" do
      class Biff
        Subject[ self, :proc, :jimmy, :memoized, :proc, :jammy ]
      end
      b = Biff.new( :jimmy, -> { 'whiles' }, :jammy, -> { 'whales' } )
      s1, s2, s3, s4 = b.jimmy, b.jammy, b.jimmy, b.jammy
      [ s1, s3 ].uniq.should eql( [ 'whiles' ] )
      [ s2, s4 ].uniq.should eql( [ 'whales' ] )
      ( s1.object_id == s3.object_id ).should eql( false )
      ( s2.object_id == s4.object_id ).should eql( true )
    end
  end
end
