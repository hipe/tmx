require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] S & R - reactive nodes - counts", wip: true do

    TS_[ self ]
    use :operations

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
