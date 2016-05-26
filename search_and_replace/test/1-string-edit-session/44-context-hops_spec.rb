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

      shared_subject :mutated_edit_session_ do

        _es = build_edit_session_
        # (hi. engage nothing.)
        _es
      end

      context "from first match" do

        shared_subject :context_lines_before_during_after_ do

          context_lines_before_during_after_via_ 2, 2
        end

        it "during" do
          for_ lines_during_ do
            _ 'wahootey41 hello41 wahootey42'
          end
        end

        it "after" do
          for_ lines_after_ do
            _ 'hello42'
            _ 'wahootey43'
          end
        end

        it "before" do
          nothing_for_ lines_before_
        end
      end

      context "from final (i.e third) match" do

        shared_subject :context_lines_before_during_after_ do

          context_lines_before_during_after_via_ 2, 2, 2
        end

        it "before" do
          for_ lines_before_ do
            _ 'wahootey41 hello41 wahootey42'
            _ 'hello42'
          end
        end

        it "during" do
          for_ lines_during_ do
            _ 'wahootey43'
          end
        end

        it "after" do
          nothing_for_ lines_after_
        end
      end
    end
  end
end
