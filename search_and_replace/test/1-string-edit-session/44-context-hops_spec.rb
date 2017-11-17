require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] SES - context hops" do

    TS_[ self ]
    use :memoizer_methods
    use :SES_context_lines

    context "(cover for the first time a matches block going backwards)" do

      given do

        str _same_string

        rx %r(\bwahootey[0-9])  # NOTE only one digit!
      end

      mutate_edit_session_for_context_lines_by do

        _es = string_edit_session_begin_
        # (hi. engage nothing.)
        _es
      end

      num_lines_before 2
      num_lines_after 2

      shared_subject :block_array do  # for SES::Block_Stream (for `at_`)

        _es = shared_edit_session_for_context_lines
        build_block_array_via_first_block _es.first_block
      end

      it "(make sure there is a static block (covers :#spot-7))" do
        at_( 0 ) == :M or fail
        at_( 1 ) == :S or fail
        at_( 2 ) == :M or fail
        block_count_ == 3 or fail
      end

      it "(output looks like input)" do
        want_edit_session_output_ _same_string
      end

      shared_subject :_same_string do

        unindent_ <<-HERE
          wahootey41 hello41 wahootey42
          hello42
          wahootey43
        HERE
      end

      context "from first match" do

        during_around_match_controller_at_index 0
        shared_context_lines

        it "during" do
          want_paragraph_for_context_stream_ during_throughput_line_stream_ do
            _ 'wahootey41 hello41 wahootey42'
          end
        end

        it "after" do
          want_paragraph_for_context_stream_ after_throughput_line_stream_ do
            _ 'hello42'
            _ 'wahootey43'
          end
        end

        it "before" do
          want_no_lines_in_ before_throughput_line_stream_
        end
      end

      context "from final (i.e third) match" do

        during_around_match_controller_at_index 2
        shared_context_lines

        it "before" do
          want_paragraph_for_context_stream_ before_throughput_line_stream_ do
            _ 'wahootey41 hello41 wahootey42'
            _ 'hello42'
          end
        end

        it "during" do
          want_paragraph_for_context_stream_ during_throughput_line_stream_ do
            _ 'wahootey43'
          end
        end

        it "after" do
          want_no_lines_in_ after_throughput_line_stream_
        end
      end
    end

    context "N lines in a previous remote matches block, and N of those" do

      # from a previous matches block get more than one line to cover that
      # it un-reverses correctly. also cover that it looks to be recursive
      # backwards (i.e hit the previous-to-the-previous matches block.)

      given do

        str _same_string
        rx %r(\b\d X)
      end

      mutate_edit_session_for_context_lines_by do
        string_edit_session_begin_
      end

      num_lines_before 10  # actually only 6 lines available
      during_around_match_controller_at_index 4  # the one on line 7
      num_lines_after 10  # actually only 1 line available

      shared_context_lines

      shared_subject :_same_string do
        unindent_ <<-HERE
          line 1 X
          line 2 X
          line 3 •
          line 4 X
          line 5 X
          line 6 •
          line 7 X
          jeff bezos
        HERE
      end

      it "(output looks like input)" do
        want_edit_session_output_ _same_string
      end

      it "before" do
        want_paragraph_for_context_stream_ before_throughput_line_stream_ do
          _ 'line 1 X'
          _ 'line 2 X'
          _ 'line 3 •'
          _ 'line 4 X'
          _ 'line 5 X'
          _ 'line 6 •'
        end
      end

      it "during" do
        want_paragraph_for_context_stream_ during_throughput_line_stream_ do
          _ 'line 7 X'
        end
      end

      it "after" do
        want_paragraph_for_context_stream_ after_throughput_line_stream_ do
          _ 'jeff bezos'
        end
      end
    end
  end
end
