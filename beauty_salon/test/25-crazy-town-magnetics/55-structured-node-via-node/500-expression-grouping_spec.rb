require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - SNvN - access', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_structured_nodes

    context '(access an lvar, assign to an ivar)' do

      # #covers:`lvar` #covers:`lvasgn`

      it 'builds' do
        structured_node_ || fail
      end

      it 'you can see how many sub-expressions there are' do
        _main_thing.length == 2 || fail
      end

      it %q{access the first sub-expression (here it's an lvar)} do
        # (this activated lvasgn but does not own it. that's in #testpoint2.2)
        _ary_ish = _main_thing
        _hi = _ary_ish.dereference 0
        _hi._node_.type == :lvasgn || fail
      end

      def structured_node_
        _this_common_structured_node
      end
    end

    context 'this one statement' do

      # #covers:`ivasgn` (do it here not there just because meh)

      it 'the expression is an ivasgn' do
        _subject._node_.type == :ivasgn || fail
      end

      it 'the left hand side (the ivar) is a symbol (INCLUDES the "@" part)' do
        _x = _subject.ivar_as_symbol
        _x == :@lefty || fail
      end

      it 'the right hand side is the coveted lvar' do
        x = _subject.zero_or_one_right_hand_side_expression
        x._node_.type == :lvar || fail
        x.symbol == :righty || fail
      end

      def _subject
        _main_thing.dereference 1
      end

      def structured_node_
        _this_common_structured_node
      end
    end

    # --

    shared_subject :_this_common_structured_node do
      structured_node_via_string_ 'righty = nil ; @lefty = righty'
    end

    # the above pair of "expressions" has emerged out of something of
    # circular dependency whose goridan know we cut with this test case. how
    # we arrived at this small tangle starts from one point of origin: 1) we
    # want to test lvar access (reading what's in a local variable). this
    # give rise to two other necessary elements:
    #
    # 2) we can't tell the ruby interpreter that something's an lvar unless
    # something is assigned to it, because otherwise it looks like a method
    # call (right?). so we require an lvasgn to have occurred somewhere in
    # the same scope before (above) the part of code we want to be
    # interpreted as an lvar access.
    #
    # as such, 3) we now require multiple "statements" (ok expressions) to
    # be evaluated as part of the same scope. simply putting them next to
    # each other interprets them as an expression group, hence this higher-
    # level construct is also employed; which now becomes employed (along
    # with (2)) in service of (1).
    #
    # as such, this story covers points "virtually" below in other places:
    # 1) the `lvasgn` assignment belongs (nominally) in #testpoint2.2
    # (assignment); and 2) the accessing of the lvar should be in
    # #testpoint2.3 (access). but as we have demonstrated above, at least
    # two of these points we cannot test in isolation; i.e they need to be
    # a part of this complete story, with all three parts in concert.
    #
    # since expression groups have the highest-level (lattermost) regression
    # precedence (as explained in the sibling README), it is this topic that
    # gets to host all of these concerns. WHEW!

    # --

    def _main_thing
      at_ :zero_or_more_expressions
    end

    # ==
    # ==
  end
end
# :#testpoint2.5
# #born.
