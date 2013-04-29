require_relative 'test-support'

module Skylab::Basic::TestSupport::Range

  ::Skylab::Basic::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Basic::Range }::Positive::Union" do

    context "prefix and postfix" do

      it "b on a normal" do
        with   '1-2,3-4'
        expect '1-2,3-4'
      end

      it "b on a touch" do
        with '1-2,2-3'
        expect '1-3'
      end

      it "b on a intersect" do
        with '1-3,2-4'
        expect '1-4'
      end

      it "b on a equal" do
        with '1-2,1-2'
        expect '1-2'
      end

      it "b on a sub" do
        with '1-4,2-3'
        expect '1-4'
      end

      it "b on a super" do
        with '1-2,1-3'
        expect '1-3'
      end

      it "a on b normal" do
        with '3-4,1-2'
        expect '1-2,3-4'
      end

      it "a on b touch" do
        with '2-3,1-2'
        expect '1-3'
      end

      it "a on b intersect" do
        with '1-3,2-4'
        expect '1-4'
      end

      it "a on b superset" do
        with '2-3,1-4'
        expect '1-4'
      end

      it "a on b c superset b c" do
        with '2-3,4-5,1-6'
        expect '1-6'
      end

      it "a on b c d superset b c" do
        with '2-3,4-5,7-8,1-6'
        expect '1-6,7-8'
      end
    end

    context "over 3" do

      it "equal outer over inner two" do
        with '1-2,4-5,6-7,9-10,4-7'
        expect '1-2,4-7,9-10'
      end

      it "fuse 2 overlapping second" do
        with '1-2,4-5,6-7,9-10,4-8'
        expect '1-2,4-8,9-10'
      end

      it "fuse 3 touching 1" do
        with '1-2,4-5,6-7,9-10,4-9'
        expect '1-2,4-10'
      end
    end

    context "infix" do

      it "b on a c normal" do
        with '1-2,5-6,3-4'
        expect '1-2,3-4,5-6'
      end

      it "b on a c touch a" do
        with '1-2,4-5,2-3'
        expect '1-3,4-5'
      end

      it "b on a c intersect a" do
        with '1-3,5-6,2-4'
        expect '1-4,5-6'
      end

      it "b on a c touch c" do
        with '1-2,4-5,3-4'
        expect '1-2,3-5'
      end

      it "b on a c intersect c" do
        with '1-2,4-6,3-5'
        expect '1-2,3-6'
      end

      it "b on a c intersect a c" do
        with '1-3,4-6,2-5'
        expect '1-6'
      end

      it "b on a c touch a c inner" do
        with '1-2,3-4,2-3'
        expect '1-4'
      end

      it "b on a c touch a c outer" do
        with '1-2,3-4,1-4'
        expect '1-4'
      end

      it "b on a c d fuse back multiple" do
        with '2-4,5-6,7-8,3-9'
        expect '2-9'
      end
    end

    def with str
      @unio = Basic::Range::Positive::Union.new
      str.split( ',' ).each do |s|
        bg, ed = s.split '-'
        @unio.add ::Range.new( bg.to_i, ed.to_i )
      end
    end

    def expect str
      @unio.describe.should eql( str )
    end
  end
end
