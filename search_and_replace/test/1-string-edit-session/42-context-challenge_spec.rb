require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] SES - context challenge" do

    TS_[ self ]
    use :memoizer_methods
    use :SES_context_lines

    context "many matches, many replacements, delimitation changed" do

      given do

        str unindent_ <<-HERE
          zero_then
          one_and
          two_and
          three_and
          four
        HERE

        rx %r(_and$)
      end

      num_lines_before 2
      num_lines_after 2
      during_around_match_controller_at_index 1

      context "replace all three" do

        mutate_edit_session_for_context_lines_by do

          cs = string_edit_session_begin_controllers_
          mc = cs.match_controller_array

          mc[ 0 ].engage_replacement_via_string "\nAND"
          mc[ 1 ].engage_replacement_via_string "_2_and"
          mc[ 2 ].engage_replacement_via_string "\nAND"

          cs.string_edit_session
        end

        it "(output looks right)" do

          want_edit_session_output_ unindent_ <<-HERE
            zero_then
            one
            AND
            two_2_and
            three
            AND
            four
          HERE
        end

        shared_context_lines

        it "the line of" do

          for_context_stream_ during_throughput_line_stream_
          for_first_and_only_line_
          want_last_atoms_ :static_continuing, :content, "two",
            :match, 1, :repl, :content, "_2_and", :static, * _NL
        end

        it "after - two lines" do
          2 == _after_lines.length or fail
        end

        it "after - first line" do
          for_context_line_ _after_lines.fetch 0
          want_last_atoms_ :static_continuing, :content, "three", :match, 2, :repl, * _NL
        end

        it "after - second line (note replacement delineation is used)" do
          for_context_line_ _after_lines.fetch 1
          want_last_atoms_ :match_continuing, :content, "AND", :static, * _NL
        end

        shared_subject :_after_lines do
          after_throughput_line_stream_.to_a
        end

        it "before - two lines" do
          2 == _before_lines.length or fail
        end

        it "before - first line" do
          for_context_line_ _before_lines.fetch 0
          want_last_atoms_ :static, :content, "one", :match, 0, :repl, * _NL
        end

        it "before - second line" do
          for_context_line_ _before_lines.fetch 1
          want_last_atoms_ :match_continuing, :content, "AND", :static, * _NL
        end

        shared_subject :_before_lines do
          before_throughput_line_stream_.to_a
        end
      end
    end

    context "repl has a repl before it, does not start at column 1, adds lines" do

      given do

        str unindent_ <<-HERE
          zip zonk zip
          zap zank zap
        HERE

        rx %r(\bz[aeiou]nk\b)i
      end

      num_lines_before 2
      num_lines_after 2
      during_around_match_controller_at_index 1

      mutate_edit_session_for_context_lines_by do

        es = string_edit_session_begin_

        mc1 = es.first_match_controller
        mc1.engage_replacement_via_string "nourk 1\nnourk 2\nnourk 3"

        mc2 = mc1.next_match_controller
        mc2.engage_replacement_via_string "nelf 1\nnelf 2\nnelf 3"

        mc2.next_match_controller and fail

        es
      end

      it "(output looks right)" do

        want_edit_session_output_ unindent_ <<-HERE
          zip nourk 1
          nourk 2
          nourk 3 zip
          zap nelf 1
          nelf 2
          nelf 3 zap
        HERE
      end

      shared_context_lines

      it "the line of - note it's three lines now. you get all three." do

        want_paragraph_for_context_stream_ during_throughput_line_stream_ do
          _ 'zap nelf 1'
          _ 'nelf 2'
          _ 'nelf 3 zap'
        end
      end

      it "there are no two after" do

        want_no_lines_in_ after_throughput_line_stream_
      end

      it "the two before (ditto)" do

        want_paragraph_for_context_stream_ before_throughput_line_stream_ do
          _ 'nourk 2'
          _ 'nourk 3 zip'
        end
      end
    end

    context "when many matches on one line and actual context is low" do

      given do

        str unindent_ <<-HERE
          zo ZE zoo
          ZIM zam ZOM
          ziff ZUP zaff
        HERE

        rx %r(\bZ[A-Z]+\b)
      end

      num_lines_before 2
      num_lines_after 2
      during_around_match_controller_at_index 1

      mutate_edit_session_for_context_lines_by do

        cs = string_edit_session_begin_controllers_
        mc = cs.match_controller_array

        mc[0].engage_replacement_via_string 'JE'
        mc[1].engage_replacement_via_string 'JIM'
        mc[2].engage_replacement_via_string 'JOM'
        mc[3].engage_replacement_via_string 'JUP'

        cs.string_edit_session
      end

      it "(content looks right)" do

        want_edit_session_output_ unindent_ <<-HERE
          zo JE zoo
          JIM zam JOM
          ziff JUP zaff
        HERE
      end

      shared_context_lines

      it "the line of" do

        want_paragraph_for_context_stream_ during_throughput_line_stream_ do
          _ 'JIM zam JOM'
        end
      end

      it "asked for two after, only got one" do

        want_paragraph_for_context_stream_ after_throughput_line_stream_ do
          _ 'ziff JUP zaff'
        end
      end

      it "asked for two before, only got one" do

        want_paragraph_for_context_stream_ before_throughput_line_stream_ do
          _ 'zo JE zoo'
        end
      end
    end
  end
end
