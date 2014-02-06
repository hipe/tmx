require_relative 'test-support'

module Skylab::Callback::TestSupport::CLI::Fire

  ::Skylab::Callback::TestSupport::CLI[ TS__ = self ]

  include CONSTANTS

  Callback::Lib_::Quickie[ self ]

  describe "[cb] CLI fire" do

    extend TS__

    it "with the ideal case - works" do
      g = Callback::Lib_::TestSupport_[]::IO::Spy::Triad.new nil
      # g.debug!
      c = Callback::CLI.new( * g.values )
      argv = [ 'fire',
        Callback.dir_pathname.join( 'core.rb' ),
        'Skylab::Callback::Test::Fixtures::ZigZag',
        'hacking' ]
      rs = c.invoke argv
      rs.should eql true
      line_a = g.errstream.string.split "\n"
      line_a.last.should match( /\AOK: #<Skylab::Callback::Event::Unified/ )
    end
  end
end
