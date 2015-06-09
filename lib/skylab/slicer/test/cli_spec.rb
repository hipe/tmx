require_relative 'test-support'

module Skylab::Slicer::TestSupport

  describe "[sli] CLI cannon" do

    extend TS_
    use :expect_CLI

    it "1.3" do

      invoke 'ping'
      expect :e, "hello from slicer."
      expect_no_more_lines
      @exitstatus.should eql :hello_from_slicer
    end
  end
end
