require_relative '../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] IO spy group" do

    it "aggregates emissions from multiple streams onto the same ordered queue" do

      g = _subject_module.new
      red = g.for :red
      blue = g.for :blue
      red.puts "r1"
      blue.puts "b1\nb2"
      red.write "r2\nnever see"
      expect( g.lines.length ).to eql(4)
      expect( g.lines.map( & :stream_symbol ) ).to eql( [ :red, :blue, :blue, :red ] )
      expect( g.lines.map(&:string).join( EMPTY_S_ ) ).to eql("r1\nb1\nb2\nr2\n")
    end

    def _subject_module
      Home_::IO.spy.group
    end
  end
end
