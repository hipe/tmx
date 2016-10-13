require_relative '../../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] models - criteria - to-stream" do

    TS_[ self ]
    use :expect_event
    use :models_criteria_actions

    it "`to_criteria_stream` lists the files that are in the folder" do

      ensure_common_setup_

      retrieve_criteria_the_long_way_( 'example' ) or fail
    end
  end
end
