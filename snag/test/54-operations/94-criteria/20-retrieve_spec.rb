require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - criteria - retrieve" do

    TS_[ self ]
    use :expect_event
    use :criteria_operations

    it "use a persistent criteria" do

      ensure_common_setup_  # begin #cp

      crit = retrieve_criteria_the_long_way_ 'example'

      crit.unmarshal or fail

      st = crit.to_reduced_entity_stream_via_collection_identifier(
        Fixture_file_[ :hot_rocket_mani ] )

      st.gets.ID.to_i.should eql 2
      st.gets.ID.to_i.should eql 4
      st.gets.ID.to_i.should eql 5
      st.gets.ID.to_i.should eql 7
      st.gets.should be_nil
    end
  end
end
