require_relative 'test-support'

module Skylab::Basic::TestSupport::Yielder

  ::Skylab::Basic::TestSupport[ self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Basic::Yielder}::Counting" do

    it "counts" do
      yes = nil
      y = Basic::Yielder::Counting.new do |msg|
        yes = msg
      end

      y.count.should eql( 0 )
      y << "hi"
      y.count.should eql( 1 )
      yes.should eql( 'hi' )
      y.yield 'a', 'b', 'c'
      yes.should eql( 'a' )  # LOOK fun fact
      y.count.should eql( 2 )
    end
  end
end
