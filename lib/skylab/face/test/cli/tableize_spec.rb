require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Tableize

  ::Skylab::Face::TestSupport::CLI[ self ]

  include Constants

  extend TestSupport_::Quickie

  Face_ = Face_

  Sandboxer = TestSupport_::Sandbox::Spawner.new

  describe "[fa] CLI tableize" do
    context "`tableize` - deprecated, see  [#036]" do
      Sandbox_1 = Sandboxer.spawn
      it "`tableize` has been deprecated.  but here's a demo" do
        Sandbox_1.with self
        module Sandbox_1
          y = [ ]
          Face_::CLI.tableize(
            [ food: 'donuts', drink: 'coffee' ],
            -> line { y << line } )
          y.shift.should eql( "|   Food  |   Drink |" )
          y.shift.should eql( "| donuts  |  coffee |" )
          y.length.should eql( 0 )
        end
      end
    end
  end
end
