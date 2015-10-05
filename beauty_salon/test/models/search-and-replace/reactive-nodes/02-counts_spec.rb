require_relative '../../../test-support'

module Skylab::BeautySalon::TestSupport

  describe "[bs] S & R - reactive nodes - counts" do

    extend TS_
    use :models_search_and_replace_reactive_nodes

    it "counts" do

      call_API(
        * common_args_,
        :counts
      )

      st = @result

      expect_neutral_event :grep_command_head
      expect_no_more_events

      o = st.gets
      st.gets.should be_nil

      o.count.should eql 2

      basename_( o.path ).should eql _THREE_LINES_FILE
    end
  end
end
