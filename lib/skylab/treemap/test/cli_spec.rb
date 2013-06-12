require_relative 'cli/test-support'

module Skylab::Treemap::TestSupport::CLI

  describe "The Treemap Module's CLI" do

    extend CLI_TestSupport

    num_streams 2  # (hack to get debug! compat)

    it "is available under the 'tmx' executable" do
      tmx_cli.invoke ['-h']
      serr.scan( /^ +treemap\b/ ).length.should eql( 1 )
    end

    it "lists render in the help screen" do
      tmx_cli.invoke ['treema', '-h']
      scn = Treemap::Bleeding::Porcelain::Services::StringScanner.new serr
      scn.skip_until( /\nactions:\n/ ) or
        fail 'failed to find "actions:" section'
      names = []
      while line = scn.scan( /^[[:space:]].*\n/ ) do
        if md = line.match( /^[[:space:]]+([-a-z]+)?/) # weak!
          if md[1]
            names.push md[1]
          else
            line.should match( /can utilize plugin/ ) # #todo this is awful
          end
        end
      end
      names.should eql( %w(ping render doobie install) )
    end
  end
end
