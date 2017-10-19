# frozen_string_literal: true

require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - NPvM - association terminal integration', ct: true do

    # :[#022.4]: terminal associations (building off ideas in [#doc])
    #
    # Overview:
    #
    #   - the idea of & utility behind "terminal node" (a "leaf node") is
    #     essential to graph theory, grammars.
    #
    #   - here we use the concept to model the end-of-the-line, primitive
    #     data of AST's (things like integers, strings and so on.)
    #
    #   - we use the concept of terminals because A) they model the
    #     tendencies of the target grammar as it appears in practice and
    #     B) our [#025.F] traversal algorithm (as probably all of them)
    #     depends on knowing which nodes are terminal vs. nonterminal.
    #
    #   - terminal assocations require a terminal type. there are no
    #     built-in terminal types. they are always user-defined.
    #
    #   - currently, the "any" modifier cannot modify any terminal
    #     association, but we can change this if ever needed.
    #
    #   - as of #history-A.2, the full suite of [#022.G] plural arities can
    #     be used with terminal associations.
    #
    # Preface:
    #
    #   - if you have any familiarity with the association grammar, the
    #     below description might seem overblown. but note that the below
    #     was synthesized before the association grammar even existed. so,
    #     you can then see traces of its beginnings here.
    #
    # Story and initial requirements
    #
    #   - story: imagine searching a document AST for every node of type
    #     `send` whose method name is a specific symbol (or string; the
    #     distinction is meaningless here). in order not to fall over on a
    #     large document (or a large number of documents), we do not want to
    #     wrap every single AST node (or even every single AST node of the
    #     type of interest) into its grammar symbol class just to find the
    #     node(s) we are looking for.
    #
    #   - requirement via design consequence: maintain a hard-coded mapping
    #     of an association name (in our case `method_name` (an arbitrary
    #     business name we chose in our grammar adaptation)) TO a specific
    #     "hard offset" that can be used to dereference the child of interest
    #     from every AST node of that given type (in our case, type `send`).
    #     huh? for AST nodes of type `send` as they are handed to us, the
    #     method name happens to be at offset `1`. somehow we need to derive
    #     this integer from the symbol `method_name`.
    #
    #   - corollary requirement: in the case of grammar symbols that have
    #     formal children with plural arities, the "hard offset" can in
    #     theory be a negative number (to count from the end of the array
    #     of children). HOWEVER the offset can never point to a child that
    #     is part of the plural arity region of the children array. i.e an
    #     association with a plural arity cannot be componentiated. if this
    #     makes no sense to you, you can safely ignore it.
    #
    # Design consequences & other details
    #
    #   - in the very old days before the child association grammar, we
    #     created "components" which was markup you added to a grammar symbol
    #     class to point to *particular* *offsets* of the actual children by
    #     name.
    #
    #   - then the "structure über alles" overhaul brought us an expressive,
    #     concise grammar a side benefit of whose was that a wrapped form
    #     of every child was accessible by name; no longer just those under
    #     associations specially marked as "component". in contrast, this
    #     made the "old way" appear as an obscure, hard-to-read API
    #     (which can be seen in the asset code that served this test file
    #     in the state immediately before #history-A.1).
    #
    #   - this kicked us into an existential quandry of exactly what a
    #     "component" is. in its received state, two salient characteristics:
    #     1) they were "writable" 2) they were terminal.
    #
    #   - since these components as they had been written were more correctly
    #     named "terminals", we have made this rename but note that this
    #     writability has carried along with it for now.
    #
    #   - as such this new synthesis makes the sensical (but not fully
    #     powerful) provision that currently you can only mutate terminal
    #     nodes (really, just dup-and-mutate)

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_ASSOCIATION_LYFE

    # (the below was proudly initiated by `tmx-test-support permute`)

    context 'non terminal, singular, no any, yes descriptive run' do

      given :chamunga_tunga_expression

      it 'builds' do
        _builds
      end

      it 'details' do
        _is_non_terminal
        _is_singular
        _is_not_is_any
        _associaton_symbol_is_as_received
      end
    end

    context 'non terminal, singular, no any, no descriptive run' do

      given :expression

      it 'builds' do
        _builds
      end

      it 'details' do
        _is_non_terminal
        _is_singular
        _is_not_is_any
        _associaton_symbol_is_as_received
      end
    end

    context 'non terminal, singular, yes any' do

      given :any_chabunkulous_dadunkulous_expression

      it 'builds' do
        _builds
      end

      it 'details' do
        _is_non_terminal
        _is_singular
        _is_is_any
        _associaton_symbol_is_as_received
      end
    end

    context 'non terminal, plural, no any' do

      given :one_or_more_zsa_zsa_expressions

      it 'builds' do
        _builds
      end

      it 'details' do
        _is_non_terminal
        _is_plural
        _is_not_is_any
        _associaton_symbol_is_as_received
      end
    end

    context 'non terminal, plural, yes any' do

      given :any_one_or_more_zsa_zsa_expression  # NOTE singular not plural at end OK

      it 'builds' do
        _builds
      end

      it 'details' do
        _is_non_terminal
        _is_plural
        _is_is_any
        _associaton_symbol_is_as_received
      end
    end

    context 'terminal, any' do

      given :any_fafooza_terminal

      it 'errors specifically', ex: true do
        _expect_exception :we_have_never_needed_terminals_to_have_the_ANY_modifier
      end
    end

    it 'terminal zero or more parses, details look OK' do

      asc = _terminal_zero_or_more
      asc || fail
      asc.is_terminal || fail
      asc.minimum_is_one && fail
      asc.maximum_is_one && fail
    end

    it 'terminal one or more parses, details look OK' do

      asc = _terminal_one_or_more
      asc || fail
      asc.is_terminal || fail
      asc.minimum_is_one || fail
      asc.maximum_is_one && fail
    end

    it 'terminal zero or one parses, details look OK' do

      asc = _terminal_zero_or_one
      asc || fail
      asc.is_terminal || fail
      asc.minimum_is_one && fail
      asc.maximum_is_one || fail
    end

    context %q{write methods for oridnary plural - NOTE we don't typecheck here} do

      it 'writes method' do
        _class_realised || fail
      end

      it 'the zero length case OK' do
        _given_AST ast_with_zero_elements_
        _how_bout_nau 0
      end

      it 'the one length case OK' do
        _given_AST ast_with_one_element_that_is_numeric_
        _how_bout_nau 1
      end

      it 'the two length case OK' do
        _given_AST ast_with_two_elements_
        _how_bout_nau 2
      end

      def _how_bout_nau d
        _ast = remove_instance_variable :@AST
        _cls = _class_realised
        _sn = _cls.via_node_ _ast
        _x_a = _sn.zero_or_more_zymbolio_terminals
        _x_a.length == d || fail
      end

      shared_subject :_class_realised do
        cls = _this_one_feature_branch.dereference :regoptoid
        cls.association_index  # kicks the realization of the associations, i.e write methods
        cls
      end
    end

    context 'write methods for winker' do

      it 'writes method' do
        _class_realised || fail
      end

      it 'the zero length case nil' do
        _given_AST ast_with_zero_elements_
        _guy.nil? || fail
      end

      it 'the one length case OK (NOTE - no type confirmation)' do
        _given_AST ast_with_one_element_that_is_numeric_
        _guy == 1234 || fail
      end

      it 'the two length case not OK' do
        _given_AST ast_with_two_elements_
        expect_exception_with_this_symbol_ :maximum_number_of_children_exceeded do
          _guy
        end
      end

      def _guy
        _ast = remove_instance_variable :@AST
        _cls = _class_realised
        _sn = _cls.via_node_ _ast
        _sn.zero_or_one_hallo_symbol_terminals
      end

      shared_subject :_class_realised do
        cls = _this_one_feature_branch.dereference :restargoid
        cls.association_index  # kicks the realization of the associations, i.e write methods
        cls
      end
    end

    context 'terminal, yes descriptive stem' do

      given :alfonso_cuaron_squaron_terminal

      it 'builds, is terminal' do
        _is_terminal
      end

      it 'the last token is the type' do
        _type :squaron
      end

      it 'the first few tokens are the stem' do
        _stem :alfonso_cuaron
      end
    end

    context 'terminal, no descriptive stem' do

      given :squaron_terminal

      it 'builds' do
        _is_terminal
      end

      it 'the last token is the type' do
        _type :squaron
      end

      it 'the type is also the stem' do
        _stem :squaron
      end
    end

    # ==

    context '(lower level) the asociation index vis-a-vis terminals' do

      it 'the association index knows it has (writable) terminals' do
        ai = _association_index
        ai.has_writable_terminals || fail
      end

      it '(redundant) an association that is not terminal knows it is not terminal' do
        _asc = _assocs.first
        _asc.is_terminal && fail
      end

      it '(redundant) the association that is terminal knows it is terminal, knows stem' do
        asc = _assocs[1]
        asc.is_terminal || fail
        asc.stem_symbol == :methodo_nameo || fail
      end

      def _assocs
        _association_index.associations
      end

      def _association_index
        _this_one_class.association_index
      end
    end

    # ==

    context 'there is (virtually) a components feature branch' do

      it 'deref' do
        _ = _this_one_class
        _hi = _.dereference_terminal_association__ :methodo_nameo
        _hi.stem_symbol == :methodo_nameo || fail
      end

      it 'list' do
        _ = _this_one_class
        scn = _.to_symbolish_reference_scanner_of_terminals_as_grammar_symbol_class__
        scn.head_as_is == :methodo_nameo || fail
        scn.advance_one
        scn.no_unparsed_exists || fail
      end
    end

    def _this_one_class
      _this_one_feature_branch.dereference :sendoid
    end

    shared_subject :_this_one_feature_branch do

      _cls = build_subclass_with_these_children_( :XX1_sendoid,
        :receiverosa_expression,
        :methodo_nameo_symbol_terminal,
        :zero_or_more_argumentoso_expressions,
      )

      _cls2 = build_subclass_with_these_children_( :XX1_regression,
        :zero_or_more_zymbolio_terminals,
      )

      _cls3 = build_subclass_with_these_children_( :XX1_resetargoid,
        :zero_or_one_hallo_symbol_terminals,  # :#testpoint1.55
      )

      build_subject_branch_(
        _cls, :Sendoid,
        _cls2, :Regoptoid,
        _cls3, :Restargoid,
        :ThisOneGuy,
      )
    end

    shared_subject :_terminal_zero_or_more do
      build_association_ :zero_or_more_squaron_terminals
    end

    shared_subject :_terminal_one_or_more do
      build_association_ :one_or_more_squaron_terminals
    end

    shared_subject :_terminal_zero_or_one do
      build_association_ :zero_or_one_squaron_terminal
    end

    def _associaton_symbol_is_as_received
      _actual = _subject.association_symbol
      _expected = given_symbol_
      _actual == _expected || fail
    end

    def _stem sym
      _subject.stem_symbol == sym || fail
    end

    def _type sym
      _subject.type_symbol == sym || fail
    end

    def _is_plural
      _subject.has_plural_arity || fail
    end

    def _is_singular
      _subject.has_plural_arity && fail
    end

    def _is_non_terminal
      _subject.is_terminal && fail
    end

    def _is_terminal
      _subject.is_terminal || fail
    end

    def _is_not_is_any
      _subject.is_any && fail
    end

    def _is_is_any
      _subject.is_any || fail
    end

    def _expect_exception sym

      expect_exception_with_this_symbol_ sym do
        build_association_ given_symbol_
      end
    end

    def _builds
      _subject || fail
    end

    def _given_AST ast
      @AST = ast
    end

    def _subject
      subject_association_
    end

    shared_subject :subject_branch_ do
      build_subject_branch_ :Moddo
    end

    def sandbox_module_
      X_ctm_npvm_ati
    end

    X_ctm_npvm_ati = ::Module.new  # const namespace for tests in this file
  end
end
# :#history-A.2: re-architect terminals to be fully plural, mostly indifferently
# :#history-A.1: begin to dismantle method-based grammar representation
# #born.
