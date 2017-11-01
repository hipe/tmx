require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - NPvM - three scanners via count', ct: true do

    # the main objective here is to realize a scanner-based re-implementation
    # of the previously imperative (and renamed in this commit)
    # `_each_association_offset_categorized`.
    #
    # this was reconceived *after* the reconception of the hooks-based
    # traversal magnetic which (shortly after this writing) will be
    # refactored to rely on the subject mechanism.
    #
    # annoying circular dependency: when we dereference a class (the first
    # time) we write its methods. we use the subject facility to write those
    # methods. although the subject tests cleverly avoid the use of classes,
    # the subject facility needs to use plural associations, and the tests
    # for plural associations use classes. anyway meh

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_structured_nodes
    use :crazy_town_traversal

    it 'too few - exception early' do
      _ai = _AI_one_sendoid
      expect_exception_with_this_symbol_ :minimum_number_of_children_not_satisfied do
        _build_compound_via_count_and_AI 1, _ai
      end
    end

    it 'too many - exception early' do
      _ai = _AI_two_dualoid
      expect_exception_with_this_symbol_ :maximum_number_of_children_exceeded do
        _build_compound_via_count_and_AI 3, _ai
      end
    end

    it 'when compound is not necessary - yes, no, no' do
      _using_range_compound _range_compound_just_enough_simple
      _is_the_empty_range_compound && fail
      _first_range || fail
      _middle_range && fail
      _last_range && fail
    end

    it 'with just enough - yes, no, no' do  # #coverpoint2.7
      _using_range_compound _range_compound_lesser
      _first_range || fail
      _middle_range && fail
      _last_range && fail
    end

    it 'with one more than minimum has first range - yes, yes, no' do  # #coverpoint2.8
      _using_range_compound _range_compound_one_more_than_minimum
      _first_range || fail
      _middle_range || fail
      _last_range && fail
    end

    it 'kleene star against zero - no, no, no' do
      _using_range_compound _range_compound_kleene_star_against_zero
      _is_the_empty_range_compound || fail
    end

    it 'kleene star against two - no, yes, no' do  # #coverpoint2.9
      _using_range_compound _range_compound_kleene_star_against_two
      _first_range && fail
      _middle_range || fail
      _last_range && fail
    end

    it 'some at end - yes, yes, yes' do  # #coverpoint2.10
      _using_range_compound _range_compound_caseoid_fuller
      _first_range || fail
      _middle_range || fail
      _last_range || fail
    end

    it 'scan all 1' do
      _scan_all _range_compound_just_enough_simple
      _same [ 0, 1 ], nil, nil
    end

    it 'scan all 2' do
      _scan_all _range_compound_lesser
      _same [ 0, 1 ], nil, nil
    end

    it 'scan all 3' do
      _scan_all _range_compound_one_more_than_minimum
      _same [ 0, 1 ], [ 2 ], nil
    end

    it 'scan all 4' do
      _using_range_compound _range_compound_kleene_star_against_zero
      _is_the_empty_range_compound
    end

    it 'scan all 5' do
      _scan_all _range_compound_kleene_star_against_two
      _childs nil, [ 0, 1 ], nil
      _assocs nil, [ 0, 0 ], nil
    end

    it 'scan all 6' do
      _scan_all _range_compound_caseoid_fuller
      _same [ 0 ], [ 1 ], [ 2 ]
    end

    it 'scan all 7' do
      _scan_all __range_compound_caseoid_even_fuller
      _childs [ 0 ], [ 1, 2 ], [ 3 ]
      _assocs [ 0 ], [ 1, 1 ], [ 2 ]
    end

    it 'cha cha' do
      a = []
      _x = _AI_four_caseoid
      _x._each_association_offset_categorized do |o|
        o.first_third do |d|
          a.push :F, d
        end
        o.middle_third do |d|
          a.push :M, d
        end
        o.final_third do |d|
          a.push :Z, d
        end
      end
      a == [ :F, 0, :M, 1, :Z, 2 ] || fail
    end

    def _same * d_a_a
      _childs_via_ary d_a_a
      _assocs_via_ary d_a_a
    end

    def _childs * d_a_a
      _childs_via_ary d_a_a
    end

    def _childs_via_ary d_a_a
      actual = remove_instance_variable :@CHILDS
      d_a_a.each_with_index do |d_a, d|
        actual.fetch( d ) == d_a || fail
      end
    end

    def _assocs * d_a_a
      _assocs_via_ary d_a_a
    end

    def _assocs_via_ary d_a_a
      actual = remove_instance_variable :@ASSOCS
      d_a_a.each_with_index do |d_a, d|
        actual.fetch( d ) == d_a || fail
      end
    end

    shared_subject :_range_compound_just_enough_simple do
      _ai = _AI_two_dualoid
      _build_compound_via_count_and_AI 2, _ai
    end

    shared_subject :_range_compound_lesser do
      _ai = _AI_one_sendoid
      _build_compound_via_count_and_AI 2, _ai
    end

    shared_subject :_range_compound_one_more_than_minimum do
      _ai = _AI_one_sendoid
      _build_compound_via_count_and_AI 3, _ai
    end

    shared_subject :_range_compound_kleene_star_against_zero do
      _ai = _AI_three_kleene_star
      _build_compound_via_count_and_AI 0, _ai
    end

    shared_subject :_range_compound_kleene_star_against_two do
      _ai = _AI_three_kleene_star
      _build_compound_via_count_and_AI 2, _ai
    end

    shared_subject :_range_compound_caseoid_fuller do
      _ai = _AI_four_caseoid
      _build_compound_via_count_and_AI 3, _ai
    end

    def __range_compound_caseoid_even_fuller
      _ai = _AI_four_caseoid
      _build_compound_via_count_and_AI 4, _ai
    end

    def _is_the_empty_range_compound
      _range_compound.is_the_empty_range_compound
    end

    def _first_range
      _range_compound.first_range
    end

    def _middle_range
      _range_compound.middle_range
    end

    def _last_range
      _range_compound.last_range
    end

    def _scan_all rc
      childs = []
      assocs = []
      rc.each_any_range_of_the_three_ranges do |r|
        if r
          scn = r.to_parallel_offset_scanner
          childs_ = []
          assocs_ = []
          begin
            childs_.push scn.current_child_offset
            assocs_.push scn.current_association_offset
            scn.advance_one
          end until scn.no_unparsed_exists
          childs.push childs_
          assocs.push assocs_
        else
          childs.push nil
          assocs.push nil
        end
      end
      @CHILDS = childs
      @ASSOCS = assocs
    end

    def _using_range_compound rc
      @RANGE_COMPOUND = rc
    end

    def _range_compound
      @RANGE_COMPOUND
    end

    # NOTE - below we construct repeats (maybe) of child association lists
    # that exist elswhere (as an intentional copy-paste). we do this like
    # so because here we need to test the association indexes in isolation
    # from their host class - realizing them within the host class causes
    # them to try to write methods to the host class, and action which uses
    # the facility we are testing.

    shared_subject :_AI_one_sendoid do
      _build_assocs(
        :receiverosa_expression,
        :methodo_nameo_zymbol_terminal,
        :zero_or_more_argumentoso_expressions,
      )
    end

    shared_subject :_AI_two_dualoid do
      _build_assocs(
        :LEFT_expression,
        :RIGHT_expression,
      )
    end

    shared_subject :_AI_three_kleene_star do
      _build_assocs(
        :zero_or_more_NOSEE_expressions,
      )
    end

    shared_subject :_AI_four_caseoid do
      _build_assocs(
        :scrutinized_expression,
        :one_or_more_expressions,
        :any_else_expression,
      )
    end

    def _build_assocs * sym_a
      _fb = feature_branch_for_traversal_one_
      main_magnetics_::NodeProcessor_via_Module::AssociationIndex___.new sym_a, _fb
    end

    def _build_compound_via_count_and_AI d, ai
      _subject_file_module::RangesCompound_via_Count[ d, ai ]
    end

    def _subject_file_module
      main_magnetics_::Dispatcher_via_Hooks
    end

    def sandbox_module_
      X_ctm_npvm_tsvc
    end

    X_ctm_npvm_tsvc = ::Module.new  # const namespace for tests in this file
  end
end
# #born.
