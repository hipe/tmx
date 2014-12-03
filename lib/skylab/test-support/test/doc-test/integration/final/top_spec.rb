require_relative 'test-support'

module Skylab::TestSupport::TestSupport::DocTest

  describe "[ts] DocTest" do

    context "will appear as the description string of your context or example." do

      Sandbox_1 = Sandboxer.spawn

      before :all do
        Sandbox_1.with self
        module Sandbox_1
          THIS_FILE_ = TestSupport_::Expect_Line::File_Shell[ __FILE__ ]

          # this comment gets included in the output because it is indented
          # with four or more spaces and is part of a code span that goes out.
        end
      end

      it "this line here is the description for the following example" do
        Sandbox_1.with self
        module Sandbox_1
          o = THIS_FILE_

          o.contains( "they will not#{' '}appear" ).should eql false

          o.contains( "will appear#{' '}as the description" ).should eql true

          o.contains( "this comment#{' '}gets included" ).should eql true

          o.contains( "this line#{' '}here is the desc" ).should eql true
        end
      end

      it "we now strip trailing colons from these description lines" do
        Sandbox_1.with self
        module Sandbox_1
          THIS_FILE_.contains( 'from these description lines"' ).should eql true
        end
      end
    end
  end
end
