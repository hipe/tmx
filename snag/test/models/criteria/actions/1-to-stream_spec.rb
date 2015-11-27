require_relative 'test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - criteria - to-stream" do

    extend TS_
    use :expect_event
    Criteria_Test_Support_[ self ]

    it "`to_criteria_stream` lists the files that are in the folder" do

      ensure_common_setup_

      retrieve_criteria_the_long_way_( 'example' ) or fail
    end
  end
end
