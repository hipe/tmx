require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] CLI - self supporting intro" do

    context "will appear as the description string of your context or example." do

      before :all do

        THIS_FILE_ = TestSupport_::Want_Line::File_Shell[ __FILE__ ]

        # this comment gets included in the output because it is indented
        # with four or more spaces and is part of a code span that goes out.
      end

      it "this line here is the description for the following example", wip: true do
        o = THIS_FILE_

        o.contains "they will not#{' '}appear" or fail

        o.contains "will appear#{' '}as the description" or fail

        o.contains "this comment#{' '}gets included" or fail

        o.contains "this line#{' '}here is the desc" or fail
      end

      it "we now strip trailing colons from these description lines", wip: true do

        THIS_FILE_.contains 'from these description lines"' or fail
      end
    end
  end
end
