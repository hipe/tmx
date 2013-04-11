require_relative 'test-support'
require 'skylab/headless/test/test-support'

module Skylab::PubSub::TestSupport::CLI::Fire

  ::Skylab::PubSub::TestSupport::CLI[ Fire_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ PubSub::CLI } fire" do

    extend Fire_TestSupport

    it "with the ideal case - works" do
      g = Headless::TestSupport::CLI::IO_Spy_Group.new nil
      # g.debug!
      c = PubSub::CLI.new( * g.values )
      argv = [ 'fire',
        PubSub.dir_pathname.join( 'core.rb' ),
        'Skylab::PubSub::Test::Fixtures::ZigZag',
        'hacking'
      ]
      rs = c.invoke argv
      rs.should eql( true )
      line_a = g.errstream.string.split "\n"
      line_a.last.should match( /\AOK: #<Skylab::PubSub::Event::Unified/ )
    end
  end
end
