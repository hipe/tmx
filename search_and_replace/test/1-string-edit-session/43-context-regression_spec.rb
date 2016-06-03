require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] SES - context regression" do

    TS_[ self ]
    use :memoizer_methods
    use :SES_context_lines

    context "(regression)" do

      given do

        str unindent_ <<-HERE
          ZE zoo
          ZIM
        HERE

        rx %r(\bZ[A-Z]+\b)
      end

      mutate_edit_session_for_context_lines_by do

        es = string_edit_session_begin_

        mc1 = es.first_match_controller
        mc1.engage_replacement_via_string 'JE'

        _mc2 = mc1.next_match_controller
        _mc2.engage_replacement_via_string 'JIM'

        es
      end

      num_lines_before 2
      num_lines_after 2
      during_around_match_controller_at_index 1

      it "(the replacement looks good)" do

        expect_edit_session_output_ unindent_ <<-HERE
          JE zoo
          JIM
        HERE
      end

      shared_context_lines

      it "during looks good" do

        expect_paragraph_for_context_stream_ during_throughput_line_stream_ do
          _ 'JIM'
        end
      end

      it "after looks good" do

        expect_no_lines_in_ after_throughput_line_stream_
      end

      it "before looks good" do

        expect_paragraph_for_context_stream_ before_throughput_line_stream_ do
          _ 'JE zoo'
        end
      end
    end
  end
end
