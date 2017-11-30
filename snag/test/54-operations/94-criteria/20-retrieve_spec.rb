require_relative '../../test-support'

module Skylab::Snag::TestSupport

  describe "[sg] operations - criteria - retrieve" do

    TS_[ self ]
    use :want_event
    use :criteria_operations

    it "use a persistent criteria" do

      ensure_common_setup_  # begin #cp

      crit = retrieve_criteria_the_long_way_ 'example'

      crit.unmarshal or fail

      _o_st = crit.to_reduced_entity_stream_via_collection_identifier(
        Fixture_file_[ :hot_rocket_mani ] )

      _actual = _o_st.map_by do |o|
        o.ID.to_i
      end

      want_these_lines_in_array_ _actual do |y|
        y << 2
        y << 4
        y << 5
        y << 7
      end
    end
  end
end
