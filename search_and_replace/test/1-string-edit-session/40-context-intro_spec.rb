require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] SES - context intro", wip: true do

    TS_[ self ]
    use :memoizer_methods
    use :SES_context_lines

    context "one block, several matches" do

      given do

        str unindent_ <<-HERE
          bunny bunnny
          buny
          bunnny
          bunie bunny
          bunny
        HERE

        rx %r(\bbun+y\b)
      end

      shared_subject :mutated_edit_session_ do

        cs = string_edit_session_begin_controllers_

        mc = cs.match_controller_array

        mc[1].engage_replacement_via_string 'BUNER'
        mc[3].engage_replacement_via_string 'BONUS'
        mc[5].engage_replacement_via_string 'BONANZA'

        cs.string_edit_session
      end

      context "no lines of context - only the line of the match" do

        shared_subject :context_lines_before_during_after_ do
          _mc = _the_third_match_controller_of_shared_thing_one
          _mc.to_contextualized_sexp_line_streams 0, 0
        end

        it "the before is nil" do
          lines_before_.should be_nil
        end

        it "the after is nil" do
          lines_after_.should be_nil
        end

        it "during" do
          one_line_( lines_during_ ).should eql "BONUS\n"
        end
      end

      context "one line before and one line after" do

        shared_subject :context_lines_before_during_after_ do
          _mc = _the_third_match_controller_of_shared_thing_one
          _mc.to_contextualized_sexp_line_streams 1, 1
        end

        it "during" do
          one_line_( lines_during_ ).should eql "BONUS\n"
        end

        it "before - one line" do
          one_line_( lines_before_ ).should eql "buny\n"
        end

        it "after - one line" do
          one_line_( lines_after_ ).should eql "bunie bunny\n"
        end
      end
    end

    def _the_third_match_controller_of_shared_thing_one

      _es = mutated_edit_session_

      match_controller_at_offset_ _es, 3  # the one on line three
    end
  end
end
