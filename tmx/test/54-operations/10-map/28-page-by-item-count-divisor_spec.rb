require_relative '../../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] operations - map - page by item count divisor" do

    TS_[ self ]
    use :operations_map

    context "first page" do

      call_by do
        call( * _same, :page_offset, 0 )
      end

      it "page size is X" do
        expect_these_ "deka", "dora", "guld"
      end
    end

    context "third page" do

      call_by do
        call( * _same, :page_offset, 2 )
      end

      it "page size is X+1" do
        expect_these_ "stern", "tyris", "gilius", "trix"
      end
    end

    context "page out of bounds" do

      call_by do
        call( * _same, :page_offset, 3 )
      end

      it "explains.." do

        ignore_common_post_operation_emissions_

        lines = nil
        expect :error, :expression, :page_content_ended_early do |y|
          lines = y
        end

        _x_a = realease_operations_call_array
        call_via_array _x_a
        _x = execute

        lines.first ==
          "stream content ended before reaching target page (1 page(s) short)" || fail

        _x == false || fail
      end
    end

    def _same
      _st = json_file_stream_GA_
      [ :map, :json_file_stream, _st, :page_by, :item_count, :page_size_denominator, 3 ]
    end
  end
end
