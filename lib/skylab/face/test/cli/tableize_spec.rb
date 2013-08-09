require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Tableize

  ::Skylab::Face::TestSupport::CLI[ self ]

  include CONSTANTS

  Face = ::Skylab::Face

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Face::CLI::Tableize" do
    context "`tableize` - deprecated, see  [#fa-036]" do
      Sandbox_1 = Sandboxer.spawn
      it "`tableize` has been deprecated.  but here's a demo" do
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
  end
end
