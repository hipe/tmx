require_relative 'test-support'

module Skylab::Callback::TestSupport::CLI::Viz

  ::Skylab::Callback::TestSupport::CLI[ TS__ = self ]

  include CONSTANTS

  Callback::Lib_::Quickie[ self ]

  describe "[cb] viz" do

    extend TS__

    it "with the ideal case - works" do
      g = Callback::Lib_::TestSupport_[]::IO::Spy::Triad.new nil
      # g.debug!
      c = Callback::CLI.new( * g.values )
      c.send :program_name=, 'pzb'
      argv = [ 'viz', fixtures_dir_pn.join( 'who-hah' ).to_s ]
      r = c.invoke argv
      g.errstream.string.should match( /\A\(pzb graph-viz got 2 / )
      g.outstream.string.should eql( "hacking->business\nhacking->pleasure\n" )
      r.should eql( true )
    end
  end
end
