require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - NPvM - association assert any, plural, group', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_structured_nodes

    it 'minimum number of children not satisfied', ex: true do

      _ast = ast_with_two_elements_
      _cls = _class_for_switchoid
      want_exception_with_this_symbol_ :minimum_number_of_children_not_satisfied do
        _go _ast, _cls
      end
    end

    it 'maximum number of children exceeded', ex: true do

      _ast = _ast_with_four_elements
      _cls = _class_for_dualoid
      want_exception_with_this_symbol_ :maximum_number_of_children_exceeded do
        _go _ast, _cls
      end
    end

    it 'against zib-bob when has too many', ex: true do

      _ast = _ast_with_three_elements
      _cls = _class_for_winker
      want_exception_with_this_symbol_ :maximum_number_of_children_exceeded do
        _go _ast, _cls
      end
    end

    it 'against zib-bob when has too few', ex: true do

      _ast = ast_with_zero_elements_
      _cls = _class_for_winker
      want_exception_with_this_symbol_ :minimum_number_of_children_not_satisfied do
        _go _ast, _cls
      end
    end

    it 'against zib-bob when the greater possible length' do

      _ast = ast_with_two_elements_
      _cls = _class_for_winker
      _vals = _want_values _ast, _cls
      _vals == [ 123, 456 ] || fail
    end

    it 'against zib-bob when has the lesser possible length (money shot)' do

      _ast = ast_with_one_element_that_is_numeric_
      _cls = _class_for_winker
      _vals = _want_values _ast, _cls
      _vals == [ 1234 ] || fail
    end

    it 'this dingus - nil' do  #coverpoint1.51

      _ast = ast_with_one_element_that_is_numeric_
      _cls = _class_for_winker
      o = _cls.via_node_ _ast
      o.lefty == 1234 || fail
      o.zero_or_one_righty_expression.nil? || fail
    end

    it 'this dingus - something (HAS RECURSION)' do  # #coverpoint1.52

      _ast0 = _build_node :numbo_tron, 456
      _ast = _build_node :meh, 3232, _ast0

      _cls = _class_for_winker
      o = _cls.via_node_ _ast
      o.lefty == 3232 || fail
      x = o.zero_or_one_righty_expression
      x || fail
      x.tha_digit == 456 || fail
    end

    it 'distribute two elements into two slots (INTERFACE EXPERIMENTAL)' do

      _ast = ast_with_two_elements_
      _cls = _class_for_dualoid
      _vals = _want_values _ast, _cls
      _vals == [ 123, 456 ] || fail
    end

    it 'distribute elements to slots when plurals (INTERFACE EXPERIMENTAL) (NOTE FLATTENING)' do

      _ast = _ast_with_four_elements
      _cls = _class_for_switchoid
      vals, ascs = _want_values_and_associations _ast, _cls

      ascs.map( & :association_symbol ) == %i(
        value_under_scrutiny_expression
        one_or_more_whon_expressions
        one_or_more_whon_expressions
        any_elze_expression
      ) || fail

      vals == [ 12, 34, 56, 78 ] || fail
    end

    it 'fail an any-ness assertion', ex: true do

      _ast = _ast_that_is_quote_winking
      _cls = _class_for_dualoid

      pairs = []
      want_exception_with_this_symbol_ :missing_expected_child do
        _write_pairs_before_exception_into pairs, _ast, _cls
      end
      pairs.length == 1 || fail
    end

    it %q{but the addition of 'any' lets the hole thru} do

      _ast = _ast_that_is_quote_winking
      _cls = _class_for_dualoid_but_winking_OK

      _vals = _want_values _ast, _cls
      _vals == [ 321, nil ] || fail
    end

    it 'group mismatch', ex: true do

      _ast = _ast_left_is_not_numeric
      _cls = _class_for_winkie

      want_exception_with_this_symbol_ :group_affiliation_not_met do
        _go _ast, _cls
      end
    end

    it %q{'any' plus 'group' with fail on other in the 'any' slot}, ex: true do

      _ast = _ast_right_is_not_numeric
      _cls = _class_for_winkie

      pairs = []
      want_exception_with_this_symbol_ :group_affiliation_not_met do
        _write_pairs_before_exception_into pairs, _ast, _cls
      end
      pairs.length == 1 || fail
    end

    context %q{'any' plus 'group' lets nil thru} do

      it 'ok.' do
        vals = _these.first
        2 == vals.length || fail
        vals[1].nil? || fail
        vals[0].type == :inty || fail
      end

      it 'note that from the association you can get the group name' do
        _ascs = _these.last
        _ascs.first.group_symbol == :numerick || fail
      end

      it 'note that even though there is no child there, the assoc comes thru' do
        ascs = _these.last
        2 == ascs.length || fail
        ascs[1].association_symbol == :any_right_numerick || fail
      end

      shared_subject :_these do

        _ast = _ast_right_is_not_present
        _cls = _class_for_winkie

        _want_values_and_associations _ast, _cls
      end
    end

    # --

    def _write_pairs_before_exception_into pairs, ast, cls
      cls.each_qualified_child ast do |*a|
        ( pairs ||= [] ).push a
      end
      fail
    end

    def _want_values ast, cls
      vals = []
      cls.each_qualified_child ast do |x|
        vals.push x
      end
      vals
    end

    def _want_values_and_associations ast, cls

      vals = [] ; ascs = []
      cls.each_qualified_child ast do |x, asc|
        vals.push x
        ascs.push asc
      end
      [ vals, ascs ]
    end

    def _go ast, cls
      cls.each_qualified_child ast do
        NOTHING_
      end
    end

    # --

    shared_subject :_ast_left_is_not_numeric do
      o = parser_AST_node_builder_
      _ast_winky_left = _ast_that_is_other
      _ast_winky_right = ast_with_one_element_that_is_numeric_
      o[ :winkie_WOULD_BE, _ast_winky_left, _ast_winky_right ]
    end

    shared_subject :_ast_right_is_not_numeric do
      o = parser_AST_node_builder_
      _ast_winky_left = ast_with_one_element_that_is_numeric_
      _ast_winky_right = _ast_that_is_other
      o[ :winkie_WOULD_BE, _ast_winky_left, _ast_winky_right ]
    end

    shared_subject :_ast_right_is_not_present do
      o = parser_AST_node_builder_
      _ast_winky_left = ast_with_one_element_that_is_numeric_
      o[ :winkie_WOULD_BE, _ast_winky_left, NOTHING_ ]
    end

    shared_subject :_ast_that_is_other do
      _build_node :other_thing, :oThEr_tHiNg
    end

    shared_subject :_ast_that_is_quote_winking do
      _build_node :dualoid_WOULD_BE, 321, nil
    end

    shared_subject :_ast_with_three_elements do
      _build_node :meh, 123, 456, 789
    end

    shared_subject :_ast_with_four_elements do
      _build_node :dualoid_WOULD_BE, 12, 34, 56, 78
    end

    alias_method :_build_node, :build_parser_AST_node_

    # --

    def _class_for_winkie
      _this_other_feature_branch.dereference :winkie
    end

    def _class_for_switchoid
      _this_one_feature_branch.dereference :switchoid
    end

    def _class_for_dualoid_but_winking_OK
      _this_one_feature_branch.dereference :dualoid_wink
    end

    def _class_for_dualoid
      _this_one_feature_branch.dereference :dualoid
    end

    def _class_for_winker
      _this_third_feature_branch.dereference :zib_bob
    end

    shared_subject :_this_third_feature_branch do

      _cls = build_subclass_with_these_children_( :XX3_1,
        :lefty_numzo_terminal,
        :zero_or_one_righty_expression,
      )

      _cls2 = build_subclass_with_these_children_( :XX3_2,
        :tha_digit_numzo_terminal,
      )

      build_subject_branch_(
        _cls, :ZibBob,
        _cls2, :NumboTron,
        :ThisThirdGuy,
      ) do
        self::TERMINAL_TYPE_SANITIZERS = {
          numzo: -> x do
            ::Integer === x  # ..
          end,
        }
      end
    end

    shared_subject :_this_other_feature_branch do

      _cls = build_subclass_with_these_children_( :MyDualoid_2,
        :left_numerick,
        :any_right_numerick,
      )

      _cls2 = build_subclass_with_these_children_( :MySingloid_2,
        :integer_value,
      )

      build_subject_branch_(
        _cls, :Winkie,
        _cls2, :Inty,
        :ThisOtherGuy,
      ) do
        self::GROUPS = {
          numerick: [
            :inty,
            :floatie,
          ],
        }
      end
    end

    shared_subject :_this_one_feature_branch do

      _cls = build_subclass_with_these_children_( :MySendoid_1,
        :value_under_scrutiny_expression,
        :one_or_more_whon_expressions,
        :any_elze_expression,
      )

      _cls2 = build_subclass_with_these_children_( :MyDualoid_1,
        :lefty_expression,
        :righty_expression,
      )

      _cls3 = build_subclass_with_these_children_( :MyWinkingDualoid_1,
        :lefty_expression,
        :any_righty_expression,
      )

      build_subject_branch_(
        _cls, :Switchoid,
        _cls2, :Dualoid,
        _cls3, :DualoidWink,
        :ThisOneGuy,
      )
    end

    # --

    def sandbox_module_
      X_ctm_npvm_aapg
    end

    X_ctm_npvm_aapg = ::Module.new  # const namespace for tests in this file
  end
end
# #born.
