require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] magnetics - (43) context regression", wip: true do

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

      shared_subject :mutated_edit_session_ do

        es = build_edit_session_

        mc1 = es.first_match_controller
        mc1.engage_replacement_via_string 'JE'

        _mc2 = mc1.next_match_controller
        _mc2.engage_replacement_via_string 'JIM'

        es
      end

      shared_subject :context_lines_before_during_after_ do
        context_lines_before_during_after_via_ 2, 2, 1
      end

      it "(the replacement looks good)" do

        expect_edit_session_output_ unindent_( <<-HERE )
          JE zoo
          JIM
        HERE
      end

      it "during looks good" do

        for_ lines_during_ do
          _ 'JIM'
        end
      end

      it "after looks good" do

        nothing_for_ lines_after_
      end

      it "before looks good" do

        for_ lines_before_ do
          _ 'JE zoo'
        end
      end
    end
  end
end
