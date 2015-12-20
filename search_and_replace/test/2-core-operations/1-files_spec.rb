require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] S & R - reactive nodes - files", wip: true do

    TS_[ self ]
    use :operations

    it "ping-esque" do

      call_API :ziffo
      expect_not_OK_event_ :child_not_found
      expect_failed
    end

    it "stream of first-pass search-space of files (`find`)" do

      call_API(
        :dirs, TS_._COMMON_DIR,
        :files, '*-line*.txt',
        :preview,
        :files,
      )

      expect_neutral_event :find_command_args
      expect_no_more_events
      basename_( @result.gets ).should eql 'one-line.txt'
      basename_( @result.gets ).should eql _THREE_LINES_FILE
      @result.gets.should be_nil
    end

    it "same but only those with matching content - note syntax isomorphs interactive" do

      call_API( * common_args_, :files )

      expect_neutral_event :grep_command_head

      stream = @result
      x = stream.gets
      stream.gets.should be_nil
      basename_( x ).should eql _THREE_LINES_FILE
    end
  end
end
