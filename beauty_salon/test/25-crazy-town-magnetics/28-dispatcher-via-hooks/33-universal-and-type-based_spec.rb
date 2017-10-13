require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - dispatcher via hooks - univeral and type-based', ct: true do

    # the main objective of this one is to help usher forth the new traveral
    # mechanism that is scanner-based and DIY-stacking, instead of arbitrary
    # method call recursion. exactly [#022.J].

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_structured_nodes
    use :crazy_town_traversal

    it '(confirm the FB builds)' do
      feature_branch_for_traversal_one_ || fail
    end

    it '(confirm the AST builds)' do
      ast_node_of_addition_of_three_integers_ || fail
    end

    it 'must be build with some hooks' do
      expect_exception_with_this_symbol_ :must_be_build_with_some_hooks do
        define_subject_magnetic_ do |_|
          NOTHING_
        end
      end
    end

    it %q{can't be build with both kinds of hooks} do
      expect_exception_with_this_symbol_ :cannot_be_build_with_both_kinds_of_hooks do
        define_subject_magnetic_ do |o|
          o.type_based_hook_box = Common_::Box.the_empty_box
          o.universal_hook = :_trueish_
        end
      end
    end

    context 'normal traversal of typical node' do

      it 'result from this whole traversal is nil' do
        _tuple.first.nil? || fail
      end

      it 'visited these nodes' do
        _hi = _tuple[1]
        _hi == [ :zend, :zend, :ind, :ind, :ind ] || fail
      end

      it 'told you the depth of each node (note you never see zero stack depth)' do
        _hi = _tuple[2]
        _hi == [ 1, 2, 3, 3, 2 ] || fail
      end

      shared_subject :_tuple do
        _this_common_tuple ast_node_of_addition_of_three_integers_
      end
    end

    it 'have zero in the plural segment - OK' do

        s = parser_AST_node_builder_

        _left_term = s[ :ind, 44 ]

        _ast = s[ :zend, _left_term, :frobulate ]

      a = _this_common_tuple _ast
      a[1] == [ :zend, :ind ] || fail
      a[2] == [ 1, 2 ] || fail
    end

    it 'fail terminal type doohah' do

        s = parser_AST_node_builder_

        _left_term = s[ :ind, '44' ]

        _ast = s[ :zend, _left_term, :frobulate ]

      expect_exception_with_this_symbol_ :terminal_type_assertion_failure do
        _this_common_tuple _ast
      end
    end

    it 'symbol specific hook - only the ones you asked for. structured.' do

      tuple = __this_other_tuple ast_node_of_addition_of_three_integers_
      3 == tuple.length || fail
      tuple.each do |n|
        # per #testpoint2.12, we get AST nodes not structured nodes, but could
        # sn._node_.type == :ind || fail
        n.type == :ind || fail
      end
    end

    context 'when the guy is at the beginning'

    context 'when the guy in the middle'

    # -- setup

    def __this_other_tuple ast_node

      these = []

      bx = Common_::Box.new
      bx.add :ind, -> x do
        these.push x
      end

      _hooks = define_subject_magnetic_ do |o|

        o.type_based_hook_box = bx

        o.grammar_symbols_feature_branch = feature_branch_
      end

      _wat = _go_hooks ast_node, _hooks
      _wat.nil? || fail

      these
    end

    def _this_common_tuple ast_node

      these_numbers = []
      these_thing_dings = []

      _hooks = define_subject_magnetic_ do |o|
        o.universal_hook = -> d, n do
          these_numbers.push d
          these_thing_dings.push n.type
        end
        o.grammar_symbols_feature_branch = feature_branch_
      end

      _wat = _go_hooks ast_node, _hooks

      [ _wat, these_thing_dings, these_numbers ]
    end

    def _go_hooks ast_node, hooks
      hooks.dispatch_wrapped_document_AST__ Crazy_Town::DoccyWrap[ ast_node ]
    end

    def feature_branch_
      feature_branch_for_traversal_one_
    end

    alias_method :subject_magnetic_, :magnetic_for_traversal_

    def sandbox_module_
      X_ctm_dvh_uatb
    end

    X_ctm_dvh_uatb = ::Module.new  # const namespace for tests in this file
  end
end
# #born.
