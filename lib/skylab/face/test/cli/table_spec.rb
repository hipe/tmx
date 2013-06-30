require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Table

  ::Skylab::Face::TestSupport::CLI[ Table_TestSupport = self ]

  include CONSTANTS

  Face = ::Skylab::Face  # increase its visibility for below modules

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::Face::CLI::Table" do
    context "`tablify` is a quick & dirty pretty table hack" do
      Sandbox_1 = Sandboxer.spawn
      it "like so" do
        Sandbox_1.with self
        module Sandbox_1
          y = [ ]

          Face::CLI::Table::FUN.tablify[
            [[ :fields, [ 'food', 'drink']],
             [ :show_header, true ]],
            -> line { y << line },
            [[ 'donuts', 'coffee' ]]]

          y.shift.should eql( '|    food |   drink |' )
          y.shift.should eql( '|  donuts |  coffee |' )
          y.length.should eql( 0 )
        end
      end
    end
  end
end
