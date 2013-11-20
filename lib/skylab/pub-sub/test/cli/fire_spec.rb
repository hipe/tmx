require_relative 'test-support'

module Skylab::PubSub::TestSupport::CLI::Fire

  ::Skylab::PubSub::TestSupport::CLI[ TS__ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "[ps] CLI fire" do

    extend TS__

    it "with the ideal case - works" do
      g = TestSupport::IO::Spy::Triad.new nil
      # g.debug!
      c = PubSub::CLI.new( * g.values )
      argv = [ 'fire',
        PubSub.dir_pathname.join( 'core.rb' ),
        'Skylab::PubSub::Test::Fixtures::ZigZag',
        'hacking' ]
      rs = c.invoke argv
      rs.should eql true
      line_a = g.errstream.string.split "\n"
      line_a.last.should match( /\AOK: #<Skylab::PubSub::Event::Unified/ )
    end
  end
end
