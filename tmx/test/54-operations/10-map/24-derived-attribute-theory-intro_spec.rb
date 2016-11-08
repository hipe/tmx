require_relative '../../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] operations - map - derived attribute" do

    TS_[ self ]
    use :operations_map
    Operations::Map::Dir02[ self ]

    context "when you try to assign directly to a derived attribute" do

      call_by do

        ignore_common_post_operation_emissions_

        _json_file = ::File.join entities_dir_path_, 'entity_four', 'not-valid.json'
        _st = Common_::Stream.via_item _json_file

        call( :map,
          :json_file_stream, _st,
          * attributes_module_by_,
          :select, :square,
        )
      end

      it "NOTE we probably just skipped it" do
        _st = _result_and_lines.first
        _x = _st.gets
        _x && fail
      end

      it "explains" do

        _y = _result_and_lines.last

        _rx = /\A"square" is a derived attribute - #{
          }cannot be assigned directly \(in .+not-valid\.json\)\z/

        _y.first =~ _rx || fail
      end

      shared_subject :_result_and_lines do

        lines = nil
        expect :error, :expression, :parse_error do |y|
          lines = y
        end

        x = send_subject_call

        [ x, lines ]
      end
    end

    context "when you select a derived attribute" do

      ordered_items_by do

        ignore_common_post_operation_emissions_

        _st = full_valid_json_file_stream_

        call( :map,
          :json_file_stream, _st,
          * attributes_module_by_,
          :select, :square,
        )
      end

      it "those entities that had the depedee attribute have the derived attribute" do

        had_a = _custom_partition.first
        had_a.length.zero? && fail
        had_a.each do |entity|
          bx = entity.box
          _exp = bx.fetch( :some_number ) ** 2
          bx.fetch( :square ) == _exp || fail
        end
      end

      it "those entities that didn't, didn't" do

        not_a = _custom_partition.last
        not_a.length.zero? && fail
        not_a.each do |entity|
          entity.box.has_name :squre and fail
        end
      end

      shared_subject :_custom_partition do
        presumably_ordered_items_.partition do |entity|
          entity.box.has_name :some_number
        end
      end
    end
  end
end
