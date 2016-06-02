require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - (44) context edges", wip: true do

    TS_[ self ]
    use :memoizer_methods
    use :SES_context_lines

    context "(regression)" do

      given do

        str unindent_ <<-HERE  # as may be seen in [ts]
          wahootey41 hello41 wahootey42
          hello42
          wahootey43
        HERE

        rx %r(\bwahootey[0-9])  # NOTE only one digit!
      end

      mutate_edit_session_for_context_lines_by do

        _es = string_edit_session_begin_
        # (hi. engage nothing.)
        _es
      end

      context "from first match" do

        num_lines_before 2
        num_lines_after 2

        it "during" do
          for_ during_throughput_line_stream_ do
            _ 'wahootey41 hello41 wahootey42'
          end
        end

        it "after" do
          for_ after_throughput_line_stream_ do
            _ 'hello42'
            _ 'wahootey43'
          end
        end

        it "before" do
          nothing_for_ before_throughput_line_stream_
        end
      end

      context "from final (i.e third) match" do

        num_lines_before 2
        num_lines_after 2
        during_around_match_controller_at_index 2

        it "before" do
          for_ before_throughput_line_stream_ do
            _ 'wahootey41 hello41 wahootey42'
            _ 'hello42'
          end
        end

        it "during" do
          for_ during_throughput_line_stream_ do
            _ 'wahootey43'
          end
        end

        it "after" do
          nothing_for_ after_throughput_line_stream_
        end
      end
    end
  end
end
