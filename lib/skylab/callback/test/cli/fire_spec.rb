require_relative 'test-support'

module Skylab::Callback::TestSupport::CLI::Fire

  ::Skylab::Callback::TestSupport::CLI[ TS__ = self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[cb] CLI fire" do

    extend TS__

    it "with the ideal case - works" do
      g = TestSupport_::IO.spy.triad nil
      # g.debug!
      c = Callback_::CLI.new( * g.values )
      argv = [ 'fire',
        Callback_.dir_pathname.join( 'core.rb' ),
        'Skylab::Callback::TestSupport::Fixtures::ZigZag',
        'hacking' ]
      rs = c.invoke argv
      rs.should eql true
      line_a = g.errstream.string.split "\n"
      line_a.last.should match( /\AOK: #<Skylab::Callback::TestSupport::.*\bMock_Old_Event/ )
    end
  end
end
