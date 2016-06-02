require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - (42) context challenge", wip: true do

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

        regexp %r(_and$)
      end

      context "replace all three" do

        shared_subject :mutated_edit_session_ do

          _cs = string_edit_session_begin_controllers_
          mc = _cs.match_controller_array

          mc[ 0 ].engage_replacement_via_string "\nAND"
          mc[ 1 ].engage_replacement_via_string "_2_and"
          mc[ 2 ].engage_replacement_via_string "\nAND"
          es
        end

        it "(output looks right)" do

          expect_edit_session_output_ unindent_( <<-HERE )
            zero_then
            one
            AND
            two_2_and
            three
            AND
            four
          HERE
        end

        shared_subject :context_lines_before_during_after_ do
          _build_same_tuple
        end

        it "the line of" do

          st = lines_during_
          _1 = st.gets
          _ = st.gets
          _ and fail

          distill_( _1 ).should eql(
            [ :orig_str, :replacement_begin, :repl_str,
              :replacement_end, :newline_sequence ] )
        end

        it "the two after (uses the replacement delineation)" do

          st = lines_after_
          _1 = st.gets
          _2 = st.gets
          st.gets and fail

          assemble_( _1 ).should eql "three\n"
          assemble_( _2 ).should eql "AND\n"
        end

        it "the two before (note the previous replace seq. spans 2 lines)" do

          st = lines_before_
          one = st.gets
          two = st.gets
          st.gets and fail

          assemble_( one ).should eql "one\n"
          distill_( one ).should eql(
            [ :orig_str, :replacement_begin, :newline_sequence ] )

          assemble_( two ).should eql "AND\n"
          distill_( two ).should eql(
            [ :repl_str, :replacement_end, :newline_sequence ] )
        end
      end
    end

    context "repl has a repl before it, does not start at column 1, adds lines" do

      given do

        str unindent_ <<-HERE
          zip zonk zip
          zap zank zap
        HERE

        regexp %r(\bz[aeiou]nk\b)i
      end

      mutate_edit_session_for_context_lines_by do

        es = string_edit_session_begin_

        _mc1 = es.first_match_controller
        _mc1.engage_replacement_via_string "nourk 1\nnourk 2\nnourk 3"

        _mc2 = _mc1.next_match_controller
        _mc2.engage_replacement_via_string "nelf 1\nnelf 2\nnelf 3"

        _mc2.next_match_controller and fail

        es
      end

      shared_subject :context_lines_before_during_after_ do
        _build_same_tuple
      end

      it "(output looks right)" do

        expect_edit_session_output_ unindent_( <<-HERE )
          zip nourk 1
          nourk 2
          nourk 3 zip
          zap nelf 1
          nelf 2
          nelf 3 zap
        HERE
      end

      it "the line of - note it's three lines now. you get all three." do

        for_ lines_during_ do
          _ 'zap nelf 1'
          _ 'nelf 2'
          _ 'nelf 3 zap'
        end
      end

      it "there are no two after" do

        nothing_for_ lines_after_
      end

      it "the two before (ditto)" do

        for_ lines_before_ do
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

        regexp %r(\bZ[A-Z]+\b)
      end

      shared_subject :mutated_edit_session_ do

        cs = string_edit_session_begin_controllers_
        mc = cs.match_controller_array

        mc[0].engage_replacement_via_string 'JE'
        mc[1].engage_replacement_via_string 'JIM'
        mc[2].engage_replacement_via_string 'JOM'
        mc[3].engage_replacement_via_string 'JUP'

        cs.string_edit_session
      end

      it "(content looks right)" do

        expect_edit_session_output_ unindent_( <<-HERE )
          zo JE zoo
          JIM zam JOM
          ziff JUP zaff
        HERE
      end

      shared_subject :context_lines_before_during_after_ do
        _build_same_tuple
      end

      it "the line of" do

        for_ lines_during_ do
          _ 'JIM zam JOM'
        end
      end

      it "asked for two after, only got one" do

        for_ lines_after_ do
          _ 'ziff JUP zaff'
        end
      end

      it "asked for two before, only got one" do

        for_ lines_before_ do
          _ 'zo JE zoo'
        end
      end
    end

    def _build_same_tuple

      context_lines_before_during_after_via_ 2, 2, 1
    end
  end
end
