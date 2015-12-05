require_relative '../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI support - table - minimal (in core)" do

    it "for expressing a [etc]" do  # #todo - inverse write

      y = Home_::CLI_Support::Table.express_minimally_into( [],
        [ food: 'donuts', drink: 'coffee' ] )

      2 == y.length or fail
      y[ 0 ].should eql "|   Food  |   Drink |"
      y[ 1 ].should eql "| donuts  |  coffee |"
    end
  end
end
