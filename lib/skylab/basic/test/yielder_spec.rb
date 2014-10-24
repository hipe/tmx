require_relative 'test-support'

module Skylab::Basic::TestSupport::Yielder

  ::Skylab::Basic::TestSupport[ self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[ba] yielder counting" do

    it "counts" do
      yes = nil
      y = Basic_::Yielder::Counting.new do |msg|
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
