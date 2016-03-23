require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] events - missing" do

    TS_[ self ]
    use :memoizer_methods

    context "(with no subject)" do

      shared_subject :__ev do

        a = []
        a.push Callback_::Name.via_variegated_symbol :foo_bar
        a.push Callback_::Name.via_variegated_symbol :quux_grault

        Home_::Events::Missing.new_with(
          :reasons, a,
        )
      end

      it "(uses \"invariant be\" form)" do

        _be_this_message = eql(
          "missing required attributes 'foo-bar' and 'quux-grault'\n" )

        _expag = common_expression_agent_
        _ev = __ev
        _ = _ev.express_into_under "", _expag

        _.should _be_this_message
      end
    end
  end
end
