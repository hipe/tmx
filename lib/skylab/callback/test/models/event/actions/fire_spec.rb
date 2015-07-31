require_relative '../test-support'

module Skylab::Callback::TestSupport

  describe "[ca] CLI - fire" do

    extend TS_

    it "with the ideal case - works" do
      g = TestSupport_::IO.spy.triad nil
      # g.debug!
      c = Home_::CLI.new( * g.values )
      argv = [ 'fire',
        Home_.dir_pathname.join( 'core.rb' ),
        'Skylab::Callback::TestSupport::Fixtures::ZigZag',
        'hacking' ]
      rs = c.invoke argv
      rs.should eql true
      line_a = g.errstream.string.split "\n"
      line_a.last.should match( /\AOK: #<Skylab::Callback::TestSupport::.*\bMock_Old_Event/ )
    end
  end
end
