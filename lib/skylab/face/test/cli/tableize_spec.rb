require_relative 'test-support'

module Skylab::Face::TestSupport::CLI

  describe "[fa] CLI::Tableize__" do

    it "`tableize` has been deprecated (use [#036]). but here's a demo" do
      y = []
      Face_::CLI.tableize(
        [ food: 'donuts', drink: 'coffee' ], -> line { y << line } )

      y.shift.should eql "|   Food  |   Drink |"
      y.shift.should eql "| donuts  |  coffee |"
      y.length.should eql 0
    end
  end
end
