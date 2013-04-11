require_relative 'test-support'
require 'skylab/headless/test/test-support'

module Skylab::PubSub::TestSupport::CLI::Viz
  ::Skylab::PubSub::TestSupport::CLI[ Viz_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  describe "#{ PubSub::CLI } viz" do

    extend Viz_TestSupport

    it "with the ideal case - works" do
      g = Headless::TestSupport::CLI::IO_Spy_Group.new nil
      # g.debug!
      c = PubSub::CLI.new( * g.values )
      c.send :program_name=, 'pzb'
      argv = [ 'viz', fixtures_dir_pn.join( 'who-hah' ).to_s ]
      r = c.invoke argv
      g.errstream.string.should match( /\A\(pzb graph-viz got 2 / )
      g.outstream.string.should eql( "hacking->business\nhacking->pleasure\n" )
      r.should eql( true )
    end
  end
end
