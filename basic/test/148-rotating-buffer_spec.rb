require_relative 'test-support'

module Skylab::Basic::TestSupport

  describe "[ba] rotating buffer" do

    TS_[ self ]
    use :memoizer_methods

    context "construct a rotating buffer with a positive integer indicating the" do

      shared_subject :rotbuf do
        rotbuf = Home_::Rotating_Buffer.new 4
        rotbuf << :a << :b << :c << :d << :e

        rotbuf
      end

      it "at that offset in the imaginary array" do
        expect( ( rotbuf[ 2 ] ) ).to eql  :d
      end

      it "the imaginary array" do
        expect( ( rotbuf[ -1 ] ) ).to eql  :e
        expect( ( rotbuf[ -4 ] ) ).to eql  :b
      end

      it "going off the \"left end\" of the imaginary array gets you" do
        expect( ( rotbuf[ -5 ] ) ).to eql  nil
      end

      it "on that topic, going off the \"right end\" of the imaginary array" do
        expect( ( rotbuf[ 4 ] ) ).to eql nil
      end

      it "a range expressed as offset and size" do
        expect( ( rotbuf[ 0, 4 ] ) ).to eql  %i( b c d e )
      end

      it "a range expressed as a range object referencing the end" do
        expect( ( rotbuf[ -2 .. -1 ] ) ).to eql  %i( d e )
      end

      it "going off the left end with a range object gets you" do
        expect( ( rotbuf[ -10 .. -1 ] ) ).to eql  nil
      end

      it "going off the right end with a range like this, however" do
        expect( ( rotbuf[ 2, 22 ] ) ).to eql  %i( d e )
      end
    end

    it "accessing the last N items will work" do
      rotbuf = Home_::Rotating_Buffer.new 5
      rotbuf << :a << :b << :c
      expect( ( rotbuf[ -3 .. -1 ] ) ).to eql %i( a b c )
    end

    it "works on not-yet-cycles buffers" do
      r = Home_::Rotating_Buffer.new 3
      r << :a << :b
      expect( r.to_a ).to eql %i( a b )
    end

    it "on a buffer that has cycled, it gives you the last N items" do
      r = Home_::Rotating_Buffer.new 3
      r << :a << :b << :c << :d
      expect( r.to_a ).to eql %i( b c d )
    end
  end
end
