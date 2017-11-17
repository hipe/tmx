require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] SES - context intro" do

    TS_[ self ]
    use :memoizer_methods
    use :SES_context_lines

    given do

      # (one block, several matches)

      str unindent_ <<-HERE
        bunny bunnny
        buny
        bunnny
        bunie bunny
        bunny
      HERE

      rx %r(\bbun+y\b)
    end

    num_lines_before 0
    during_around_match_controller_at_index 3
    num_lines_after 0

    context "with nothing engaged" do

      mutate_edit_session_for_context_lines_by do
        string_edit_session_begin_
      end

      shared_context_lines

      it "first ever throughput line - atoms show match boundary before newline" do  # (it is)

        for_context_stream_ during_throughput_line_stream_
        for_first_and_only_line_
        want_last_atoms_ :match, 3, :orig, :content, "bunnny", :static, * _NL
        end_want_atoms_
      end
    end

    context "with some things engaged" do

      mutate_edit_session_for_context_lines_by do

        cs = string_edit_session_begin_controllers_

        mc = cs.match_controller_array

        mc[1].engage_replacement_via_string 'BUNER'
        mc[3].engage_replacement_via_string 'BONUS'
        mc[5].engage_replacement_via_string 'BONANZA'

        cs.string_edit_session
      end

      context "no lines of context - only the line of the match" do

        shared_context_lines

        it "no before lines" do

          want_no_lines_in_ before_throughput_line_stream_
        end

        it "no after lines" do

          want_no_lines_in_ after_throughput_line_stream_
        end

        it "during - atoms show both replacement vs original characters" do

          for_context_stream_ during_throughput_line_stream_
          for_first_and_only_line_
          want_last_atoms_ :match, 3, :repl, :content, "BONUS", :static, * _NL
        end
      end

      context "one line before and one line after" do

        num_lines_before 1
        num_lines_after 1

        shared_context_lines

        it "during" do

          for_context_stream_ during_throughput_line_stream_
          for_first_and_only_line_
          want_last_atoms_ :match, 3, :repl, :content, "BONUS", :static, * _NL
        end

        it "after - one line - NOTE: continues the context of previous section" do

          for_context_stream_ after_throughput_line_stream_
          for_first_and_only_line_
          want_atoms_ :static_continuing, :content, "bunie "
          want_last_atoms_ :match, 4, :orig, :content, "bunny", :static, * _NL
        end

        it "before - one line" do

          for_context_stream_ before_throughput_line_stream_
          for_first_and_only_line_
          want_last_atoms_ :match, 2, :orig, :content, "buny", :static, * _NL
        end
      end
    end
  end
end
