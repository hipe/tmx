require_relative '../../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] operations - map - select intro" do

    TS_[ self ]
    use :operations_map

    context "no formal attribute collection" do

      call_by do

        ignore_common_post_operation_emissions_

        call :map, :json_file_stream, Common_::THE_EMPTY_STREAM, :select, :wipple_wapper
      end

      it "hi" do
        _act = only_line_via_this_kind_of_failure(
          :error, :expression, :parse_error, :contextually_missing )
        _act.include?( 'cannot use :select without :attributes_module_by' ) || fail
      end
    end

    context "bad attribute" do

      call_by do

        ignore_common_post_operation_emissions_

        call( :map,
          :json_file_stream, json_file_stream_01_,
          * real_attributes_,
          :select, :wipple_wapper,
        )
      end

      it "hi" do

        _act = only_line_via_this_kind_of_failure(
          :error, :expression, :parse_error, :unknown_attribute )
        _act.include?( 'unrecognized attribute ":wipple_wapper". did you mean :' ) || fail
      end
    end

    context "good attribute" do

      call_by do

        ignore_common_post_operation_emissions_

        call( :map,
          :json_file_stream, json_file_stream_01_,
          * real_attributes_,
          :select, :category,
        )
      end

      it "resultant items still do the name in the same way" do
        _two_items.first.get_filesystem_directory_entry_string == "zagnut" || fail
      end

      it "resultant items have a box, if the component is not in JSON file, not in box" do
        _two_items.first.box.length.zero? || fail
      end

      it "and if is in JSON file (and selected), is in box" do
        _two_items.last.box.fetch( :category ) == "big loada" || fail
      end

      shared_subject :_two_items do
        st = send_subject_call
        [ st.gets, st.gets ]
      end
    end
  end
end
