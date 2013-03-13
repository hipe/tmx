require_relative 'test-support'

module Skylab::TestSupport::TestSupport::IO
  ::Skylab::TestSupport::TestSupport[ IO_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ TestSupport::IO::Spy::Group }" do
    it "aggregates emissions from multiple streams onto the same ordered queue" do
      g = TestSupport::IO::Spy::Group.new
      red = g.stream_spy_for :red
      blue = g.stream_spy_for :blue
      red.puts "r1"
      blue.puts "b1\nb2"
      red.write "r2\nnever see"
      g.lines.length.should eql(4)
      g.lines.map(&:stream_name).should eql([:red, :blue, :blue, :red])
      g.lines.map(&:string).join('').should eql("r1\nb1\nb2\nr2\n")
    end
  end
end
