require_relative '../test-support'

module Skylab::Headless::TestSupport::Services::File
  ::Skylab::Headless::TestSupport::Services[ File_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ Headless::Services }::File::Lines::Producer" do

    tmpdir = File_TestSupport.tmpdir

    it "when build with pathname - `gets` - works as expected" do
      if false
      pn = tmpdir.clear.write 'foo.txt', <<-O.unindent
        one
        two
      O
      end
      pn = tmpdir.join 'foo.txt'
      l = Headless::Services::File::Lines::Producer.new pn
      l.line_number.should eql( nil )
      l.gets.should eql( "one\n" )
      l.line_number.should eql( 1 )
      l.gets.should eql( "two\n" )
      l.line_number.should eql( 2 )
      l.gets.should eql( nil )
      l.line_number.should eql( 2 )
      l.gets.should eql( nil )
    end

    it "when built with array of lines - `gets` - works the same" do
      l = Headless::Services::Array::Lines::Producer.new [ "one b\n", "two b\n" ]
      l.line_number.should eql( nil )
      l.gets.should eql( "one b\n" )
      l.line_number.should eql( 1 )
      l.gets.should eql( "two b\n" )
      l.line_number.should eql( 2 )
      l.gets.should eql( nil )
      l.line_number.should eql( 2 )
      l.gets.should eql( nil )
    end
  end
end
