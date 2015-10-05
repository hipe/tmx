require_relative 'test-support'

module Skylab::Basic::TestSupport::Rotating_Buffer

  ::Skylab::Basic::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  Home_ = Home_

  Subject_ = -> * x_a, & p do
    if x_a.length.nonzero? || p
      Home_::Rotating_Buffer[ * x_a, & p ]
    else
      Home_::Rotating_Buffer
    end
  end

  describe "[ba] Rotating_Buffer" do

    it "is just like tivo" do
      rotbuf = Subject_[].new 4
      rotbuf << :a << :b << :c << :d << :e
      rotbuf[ 2 ].should eql :d
      rotbuf[ -1 ].should eql :e
      rotbuf[ -4 ].should eql :b
      rotbuf[ -5 ].should eql nil
      rotbuf[ 0, 4 ].should eql %i( b c d e )
      rotbuf[ -2 .. -1 ].should eql %i( d e )
      rotbuf[ -10 .. -1 ].should eql nil
      rotbuf[ 2, 22 ].should eql %i( d e )
    end
    it "accessing the last N items will work" do
      rotbuf = Subject_[].new 5
      rotbuf << :a << :b << :c
      rotbuf[ -3 .. -1 ].should eql %i( a b c )
    end
    context "you can use `to_a` on a rotating buffer" do

      let :r do
        Subject_[].new 3
      end
      it "works on not-yet-cycles buffers" do
        r << :a << :b
        r.to_a.should eql %i( a b )
      end
      it "on a buffer that has cycled, it gives you the last N items" do
        r << :a << :b << :c << :d
        r.to_a.should eql %i( b c d )
      end
    end
  end
end
