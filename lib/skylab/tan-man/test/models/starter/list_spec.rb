require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Starter

  describe "[tm] models starter list" do

    extend TS_

    it "lists the two items, from the filesystem" do

      call_API :starter, :ls

      expect_no_events

      st  = @result

      st.gets.natural_key_string.should eql 'digraph.dot'

      st.gets.natural_key_string.should eql 'holy-smack.dot'

      st.gets.should be_nil

    end
  end
end
