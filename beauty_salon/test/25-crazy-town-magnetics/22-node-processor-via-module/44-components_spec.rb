require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - NPvM - components', ct: true do

    # :[#022.4]: components (building off ideas in [#doc])
    #
    # Synopsis:
    #
    #   - may be a transitional hybrid of a 'feature'
    #
    #   - an association can be "promoted" to be considered (also) a
    #     "component" (meaning below) by using the "component" keyword as
    #     the last term in the association's name (for example,
    #     `left_side_expression_component`).
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
    #   - this is a proto-fitting (opposite of retro-fitting, get it?) of
    #     components as they existed in the pre-new-way way.
    #
    #   - the old was was was obscure, hard-to-read API
    #
    #   - this new way aims to be an afterthought that fits in nicely
    #     with the "associations" (formal children) architecture.
    #
    #   - don't get too attached, because we may do away with all of this:
    #     it may be that we can isomorph componentiation to something
    #     obvious in the metadata, like stipulating that the children are
    #     primaries (like integers or symbols), or something about group
    #     associations; but before we can know what this simplification would
    #     require, we have to finish #open [#022] melting the 4 classes.

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_THIS_STUFF

    context '(minimal pairs)' do

      it 'the association index knows it has components' do
        ai = _association_index
        ai.has_components || fail
      end

      it 'an association that is not a component knows it is not a component' do
        _asc = _assocs.first
        _asc.is_component && fail
      end

      it 'the association that is a component knows it is a component, knows stem' do
        asc = _assocs[1]
        asc.is_component || fail
        asc.stem_symbol == :methodo_nameo || fail
      end

      def _assocs
        _association_index.associations
      end

      def _association_index
        _this_one_class.children_association_index
      end
    end

    context 'there is (virtually) a components feature branch' do

      it 'deref' do
        _ = _this_one_class
        _hi = _.DEREFERENCE_COMPONENT :methodo_nameo
        _hi.stem_symbol == :methodo_nameo || fail
      end

      it 'list' do
        _ = _this_one_class
        scn = _.to_symbolish_reference_scanner_OF_COMPONENTS
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
        :methodo_nameo_expression_component,
        :zero_or_more_argumentoso_expressions,
      )

      build_subject_branch_(
        _cls, :Sendoid,
        :ThisOneGuy,
      )
    end

    def sandbox_module_
      X_ctm_npvm_comp
    end

    X_ctm_npvm_comp = ::Module.new  # const namespace for tests in this file
  end
end
# #born.
