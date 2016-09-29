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
        ( rotbuf[ 2 ] ).should eql  :d
      end

      it "the imaginary array" do
        ( rotbuf[ -1 ] ).should eql  :e
        ( rotbuf[ -4 ] ).should eql  :b
      end

      it "going off the \"left end\" of the imaginary array gets you" do
        ( rotbuf[ -5 ] ).should eql  nil
      end

      it "on that topic, going off the \"right end\" of the imaginary array" do
        ( rotbuf[ 4 ] ).should eql nil
      end

      it "a range expressed as offset and size" do
        ( rotbuf[ 0, 4 ] ).should eql  %i( b c d e )
      end

      it "a range expressed as a range object referencing the end" do
        ( rotbuf[ -2 .. -1 ] ).should eql  %i( d e )
      end

      it "going off the left end with a range object gets you" do
        ( rotbuf[ -10 .. -1 ] ).should eql  nil
      end

      it "going off the right end with a range like this, however" do
        ( rotbuf[ 2, 22 ] ).should eql  %i( d e )
      end
    end

    it "accessing the last N items will work" do
      rotbuf = Home_::Rotating_Buffer.new 5
      rotbuf << :a << :b << :c
      ( rotbuf[ -3 .. -1 ] ).should eql %i( a b c )
    end

    it "works on not-yet-cycles buffers" do
      r = Home_::Rotating_Buffer.new 3
      r << :a << :b
      r.to_a.should eql %i( a b )
    end

    it "on a buffer that has cycled, it gives you the last N items" do
      r = Home_::Rotating_Buffer.new 3
      r << :a << :b << :c << :d
      r.to_a.should eql %i( b c d )
    end
  end
end
