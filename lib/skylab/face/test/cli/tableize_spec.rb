require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Tableize

  ::Skylab::Face::TestSupport::CLI[ Tableize_TestSupport = self ]

  include CONSTANTS

  Face = ::Skylab::Face  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Face::CLI::Tableize" do
    context "context 1" do
      Sandbox_1 = Sandboxer.spawn
      it "`tableize` has been deprecated for `tablify`. but here's a demo:" do
        Sandbox_1.with self
        module Sandbox_1
          y = [ ]
          Face::CLI::Tableize::FUN.tableize[
            [ food: 'donuts', drink: 'coffee' ], -> line { y << line } ]

          y.shift.should eql( "|   Food  |   Drink |" )
          y.shift.should eql( "| donuts  |  coffee |" )
          y.length.should eql( 0 )
        end
      end
    end
    context "context 2" do
      Sandbox_2 = Sandboxer.spawn
      it "usage:" do
        Sandbox_2.with self
        module Sandbox_2
          y = [ ]
          Face::CLI::Tableize::FUN.tablify[
            [ 'food', 'drink' ],
            [[ 'donuts', 'coffee' ]], -> line { y << line } ]

          y.shift.should eql( '|   food  |   drink |' )
          y.shift.should eql( '| donuts  |  coffee |' )
          y.length.should eql( 0 )
        end
      end
    end
  end
end
