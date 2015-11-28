require_relative '../../test-support'

module Skylab::TanMan::TestSupport

  describe "[tm] models starter list" do

    TS_[ self ]
    use :models

    it "lists the two items, from the filesystem" do

      call_API :starter, :ls

      expect_no_events

      st  = @result

      st.gets.natural_key_string.should eql 'digraph.dot'

      st.gets.natural_key_string.should eql 'holy-smack.dot'

      st.gets.natural_key_string.should eql 'minimal.dot'

      st.gets.should be_nil

    end
  end
end
