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
    #   - experimentally the association grammar is written such that:
    #     A) you cannot model terminals with a truly plural assocation
    #     (fortunately the target grammar is OK with this) and B) terminals
    #     must be defined with a terminal type (any mono-tokened symbolic
    #     name) that will be used to sanity check the type of the terminal
    #     and C) you *can* define the any-ness of the terminal association.
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
    #   - then the "structured uber alles" overhaul brought us an expressive,
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

    context 'terminal, plural - normally not allowed EXPERIMENTAL' do

      given :one_or_more_fafooza_terminals

      it 'errors specifically', ex: true do
        _expect_exception :terminals_cannot_currently_be_plural_for_lack_of_need
      end
    end

    context 'terminal, plural - this one kind allowed EXPERIMENTAL' do

      given :zero_or_one_FAZOOZA_symbol_terminals

      it 'builds' do
        _builds
      end

      it 'details' do
        _is_terminal
        _is_plural
      end
    end

    context 'terminal, any' do

      given :any_fafooza_terminal

      it 'errors specifically', ex: true do
        _expect_exception :we_have_never_needed_terminals_to_have_the_ANY_modifier
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

      _cls = build_subclass_with_these_children_( :XX1,
        :receiverosa_expression,
        :methodo_nameo_symbol_terminal,
        :zero_or_more_argumentoso_expressions,
      )

      build_subject_branch_(
        _cls, :Sendoid,
        :ThisOneGuy,
      )
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
# :#history-A.1: begin to dismantle method-based grammar representation
# #born.
