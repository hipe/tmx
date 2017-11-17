require_relative '../../test-support'

module Skylab::TMX::TestSupport

  describe "[tmx] operations - map - page by - item count" do

    TS_[ self ]
    use :operations_map

    context "first three" do

      call_by do
        call( * _same, :page_offset, 0 )
      end

      it "ok" do
        want_these_ "deka", "dora", "guld"
      end
    end

    context "second three" do

      call_by do
        call( * _same, :page_offset, 1 )
      end

      it "ok" do
        want_these_ "damud", "goah", "adder"
      end
    end

    context "the FOR NOW last page that is (per usual) partial" do

      call_by do
        call( * _same, :page_offset, 3 )
      end

      it "ok" do
        want_these_ "trix"  # 1 is N modulo 3
      end
    end

    context "currently, you can't use negative offsets (FOR NOW)" do

      call_by do
        call( * _same, :page_offset, -1 )
      end

      it "event etc" do

        ignore_common_post_operation_emissions_

        ev = nil
        want :error, :invalid_property_value do |ev_|
          ev = ev_
        end

        send_subject_call

        _act = ev.express_into_under "", expression_agent  # ..
        _act == ":page_offset must be non-negative, had -1" || fail
      end

      def expression_agent
        oldschool_jimmy_
      end
    end

    context "page outside of range" do

      call_by do
        call( * _same, :page_offset, 4 )
      end

      it "results in stream, stream is empty, emits an error emission" do

        ignore_common_post_operation_emissions_

        lines = nil
        want :error, :expression, :page_content_ended_early do |y|
          lines = y
        end

        _x_a = realease_operations_call_array
        call_via_array _x_a

        _x = finish_by do |st|
          st.gets
        end

        lines.first ==
          "stream content ended before reaching target page (had 2 to go)" || fail

        _x == false || fail
      end
    end

    def _same
      _st = json_file_stream_GA_
      [ :map, :json_file_stream, _st, :page_by, :item_count, :page_size, 3 ]
    end
  end
end
