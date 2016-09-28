module Skylab::DocTest

  class TestDocumentMutationMagnetics_::Plan_via_AssetNodes_and_TestDocumentIndex  # 1x

    # exactly as the "workhorse" step of [#035] (probably step 2),
    # and see "code notes" there.

    def initialize node_st, index, & l
      @listener = l
      @node_stream = node_st
      @test_document_index = index
    end

    def execute
      __prepare
      _ok = __recurse
      _ok && __finish
    end

    def __prepare
      @clobber_queue = []
      @dandy_queue = []
      NIL
    end

    def __recurse

      # the stream of toplevel nodes we are getting from the document,
      # pretend that they are the same stream of particulars we will get
      # from a context node.

      _st = @node_stream.map_by do |abstract|
        abstract.to_particular_paraphernalia
      end

      _ = Recurse__.into_with_for _st, @test_document_index.branch_index, self
      _ok :@__plan_array, _
    end

    def __finish

      cq = remove_instance_variable :@clobber_queue
      if cq.length.zero?
        cq = NOTHING_
      end

      ct = remove_instance_variable :@__plan_array
      if ct.length.zero?
        ct = NOTHING_
      end

      dq = remove_instance_variable :@dandy_queue
      if dq.length.zero?
        dq = NOTHING_
      end

      # (for now the above 3 are spelled out for coverage)

      Plan___.new cq, ct, dq
    end

    attr_reader(
      :clobber_queue,
      :dandy_queue,
      :listener,
      :test_document_index,
    )

    # ==

    class Recurse__

      # because it's algorithmically convenient, result is a possibly zero-
      # length array representing the creation branch, whereas the other two
      # target structures (queues) are written to via mutate-in-place
      # arguments. IFF soft fatal error, result will instead be false-ish.

      class << self
        def into_with_for particular_stream, bi, args
          new(
            args.clobber_queue,
            args.dandy_queue,
            particular_stream,
            bi,
            args.test_document_index,
            & args.listener
          ).execute
        end
        private :new
      end  # >>

      def initialize cq, dq, ps, bi, tdi, & l

        if bi
          if bi.is_of_branch
            has_some = bi.child_node_indexes.length.nonzero?
            use_bi = bi
          else
            NOTHING_  # #coverpoint5-4
          end
        end

        @branch_index = use_bi
        @_creation_branch = nil  # array
        @clobber_queue = cq
        @dandy_queue = dq
        @_did_see_const_definition = false
        @_document_has_first_content = has_some
        @listener = l
        @__particular_stream = ps
        @_previous_plan = nil
        @test_document_index = tdi
      end

      def execute
        ok = ACHIEVED_
        st = remove_instance_variable :@__particular_stream
        begin
          no = st.gets
          no || break
          ok = send SHAPE___.fetch( no.paraphernalia_category_symbol ), no
          ok ? redo : break
        end while above
        ok && __release_branch_result
      end

      def __release_branch_result
        a = remove_instance_variable :@_creation_branch
        if a
          a.freeze  # not sure..
        else
          EMPTY_A_
        end
      end

      SHAPE___ = {
        context_node: :_process_node_of_interest,
        const_definition: :__process_const_definition,
        example_node: :_process_node_of_interest,
        shared_subject: :__process_shared_subject,
      }

      # --
      # in the many of the guys below, we'll be taking memos to effect our
      # own branch-local version of (exactly) [#033] the fine and dandy algo
      # --

      def _process_node_of_interest no  # example node or context node

        @_node_of_interest = no

        _ = TestDocumentMutationMagnetics_::
            TransitionCharacterization_via_LeftNode_and_TestDocumentIndex.new(
          no, @test_document_index )

        c14n = _.execute
        if c14n
          @_characterization = c14n
          send NODE_OF_INTEREST_VERB__.fetch c14n.verb_symbol
        else
          c14n  # false-ish
        end
      end

      NODE_OF_INTEREST_VERB__ = {
        create: :__when_create_node_of_interest,
        downgrade: :__when_downgrade,
        same_shape: :__when_edit_existing_node_of_interest,
        upgrade: :__when_upgrade,
      }

      def __when_edit_existing_node_of_interest
        if @_characterization.is_of_branch
          __when_edit_existing_context
        else
          __when_replace_example
        end
      end

      def __when_create_node_of_interest
        if @_characterization.is_of_branch
          __when_create_context_node
        else
          __when_create_example_node
        end
      end

      def __when_downgrade  # #not-covered
         # when left is item and right is branch, it's a "DOWNGRADE" - can't
         k = @_characterization.identifying_string
         @listener.call :error, :expression, :will_not_downgrade do |y|
          y << "won't downgrade from context to example - #{ k.inspect }"
          y << "(information will be lost)"
        end
        UNABLE_
      end

      def __when_upgrade

        # recurse. if empty, disregard. otherwise, add to the CLOBBER queue.

        _with_nonzero_length_creation_branch_from_recurse do |cb|

          _eni = @_characterization.existing_node_index  # NOT used in the above

          plan = Plan__::Upgrade[ _eni, cb, @_node_of_interest ]
          @_previous_plan = plan
          _add_to_clobber_queue plan
        end
      end

      def __when_edit_existing_context

        # recurse. if empty, disregard. otherwise, add to the dandy queue.

        eni = @_characterization.existing_node_index

        _with_nonzero_length_creation_branch_from_recurse eni do |cb|

          plan = Plan__::Merge_context[ eni, cb, @_node_of_interest ]
          @_previous_plan = plan
          __add_to_dandy_queue plan
        end
      end

      def __when_create_context_node

        # recurse. if empty, disregard. otherwise, add to creation branch.

        _with_nonzero_length_creation_branch_from_recurse do |cb|

          _plan = Plan__::Insert_context[ @_node_of_interest, cb, @_previous_plan ]
          @_previous_plan = _plan  # NOT SURE
          _add_node_of_interest_to_creation_branch _plan
        end
      end

      def _with_nonzero_length_creation_branch_from_recurse existing_node_index=nil

        # an abstraction of the common pattern -
        # fail on failure, ignore (but succeed) on no-op branches.

        creation_branch = _recurse existing_node_index
        if creation_branch
          if creation_branch.length.zero?
            ACHIEVED_
          else
            yield creation_branch
          end
        else
          creation_branch  # assume soft fatal
        end
      end

      def __when_create_example_node

        # #coverpoint3-1 - prepend this node before the first node in the doc
        # #coverpoint3-3 - place this node immediately after last inserted node

        _plan = Plan__::Insert_example[ @_node_of_interest, @_previous_plan ]

        _add_node_of_interest_to_creation_branch _plan
      end

      def _add_node_of_interest_to_creation_branch plan

        _positionalize_plan plan
        _add_to_creation_branch plan
      end

      def __when_replace_example  # #coverpoint3-2
        # simply add to clobber queue. it's the only answer and the only way

        plan = Plan__::Replace_example.call(
          @_node_of_interest, @_characterization.existing_node_index, @_previous_plan )

        @_previous_plan = plan
        _add_to_clobber_queue plan
      end

      def _positionalize_plan plan
        @_previous_plan = plan
        if ! @_document_has_first_content
          @_document_has_first_content = false
          plan.become_first_content
        end
        NIL
      end

      def _recurse branch_index=nil

        # a context node *is* a branch node (the only kind we recognize here)

        _parti_st = @_node_of_interest.to_particular_paraphernalia_stream

        self.class.into_with_for _parti_st, branch_index, self
      end

      # ~

      def __process_const_definition no
        if @_did_see_const_definition
          self._COVER_ME_MULTIPLE_const_definitionS
        else
          @_did_see_const_definition = true
          __do_process_const_definition no
        end
      end

      def __do_process_const_definition no

        # this algorithm is composed (perhaps solely) of conceptual elements
        # found elsewhere, but in a composition that is unique to this case:
        # because at any branch node there can only be one (for now),
        # *at this branch node* if there's *any* existing one, replace it.
        # otherwise we'll place it after any most recently noted node, or
        # otherwise prepend.
        # (also, this must be moved to the choices)

        bi = @branch_index
        if bi
          if bi.has_before_all
            _do_replace = true
          end
        end  # (if no branch index then no branch ergo all items will be "create")

        if _do_replace
          plan = Plan__::Replace_const_def[ no, @branch_index.before_all_block ]
          @_previous_plan = plan
        else
          plan = Plan__::Insert_const_def[ no, @_previous_plan ]
          _positionalize_plan plan
        end

        _add_to_creation_branch plan
      end

      # ~

      def __process_shared_subject pc  # pc=particular compoent

        if @branch_index
          __maybe_replace_shared_subject pc
        else
          _insert_this_shared_subject pc
        end
      end

      def __maybe_replace_shared_subject pc

        match = pc.to_branch_local_document_node_matcher

        di = @branch_index.to_stream_of( :shared_subject ).flush_until_detect do |di_|

          match[ di_.existing_child_document_node ]
        end

        if di
          plan = Plan__::Replace_shared_subject[ pc, di, @_previous_plan ]
          @_previous_plan = plan
          _add_to_clobber_queue plan
        else
          _insert_this_shared_subject pc
        end
      end

      def _insert_this_shared_subject ss
        plan = Plan__::Insert_shared_subject[ ss, @_previous_plan ]
        _positionalize_plan plan
        _add_to_creation_branch plan
      end

      # --

      def _add_to_creation_branch plan
        ( @_creation_branch ||= [] ).push plan
        ACHIEVED_
      end

      def __add_to_dandy_queue plan
        @dandy_queue.push plan
        ACHIEVED_
      end

      def _add_to_clobber_queue plan
        @clobber_queue.push plan
        ACHIEVED_
      end

      attr_reader(
        :clobber_queue,
        :dandy_queue,
        :listener,
        :node_stream,
        :test_document_index,
      )
    end

    def _ok ivar, x
      if x
        instance_variable_set ivar, x ; ACHIEVED_
      else
        x
      end
    end

    # ==

    Plan___ = ::Struct.new :clobber_queue, :creation_tree, :dandy_queue

    module Plan__

      Upgrade = -> eg_node_index, a, no do
        o = NodePlan__.new
        o.existing_node_index = eg_node_index
        o.plan_array = a
        o.new_node = no
        o.plan_verb = :upgrade
        o.finish
      end

      Merge_context = -> eni, a, no do
        o = NodePlan__.new
        o.existing_node_index = eni
        o.plan_array = a
        o.new_node = no
        o.node_shape = :context
        o.plan_verb = :merge
        o.finish
      end

      Insert_context = -> cn, a, pp do
        o = NodePlan__.new
        o.new_node = cn
        o.plan_array = a
        o.previous_plan = pp
        o.node_shape = :context
        o.plan_verb = :create
        o.finish
      end

      Replace_const_def = -> nn, en do
        o = NodePlan__.new
        o.existing_node = en
        o.new_node = nn
        o.node_shape = :const_definition
        o.plan_verb = :replace
        o.finish
      end

      Insert_const_def = -> nn, pp do
        o = NodePlan__.new
        o.previous_plan = pp
        o.new_node = nn
        o.node_shape = :const_definition
        o.plan_verb = :create
        o.finish
      end

      Replace_shared_subject = -> nn, eni, pp do
        o = NodePlan__.new
        o.existing_node_index = eni
        o.new_node = nn
        o.previous_plan = pp
        o.node_shape = :shared_subject
        o.plan_verb = :replace
        o.finish
      end

      Insert_shared_subject = -> no, pp do
        o = NodePlan__.new
        o.previous_plan = pp
        o.new_node = no
        o.node_shape = :shared_subject
        o.plan_verb = :create
        o.finish
      end

      Replace_example = -> nn, eni, pp do
        o = NodePlan__.new
        o.existing_node_index = eni
        o.new_node = nn
        o.previous_plan = pp
        o.node_shape = :example
        o.plan_verb = :replace
        o.finish
      end

      Insert_example = -> nn, pp do
        o = NodePlan__.new
        o.new_node = nn
        o.previous_plan = pp
        o.node_shape = :example
        o.plan_verb = :create
        o.finish
      end
    end

    class NodePlan__

      def dup_by
        o = dup
        yield o
        o.freeze
      end

      def finish
        self
      end

      def become_first_content
        @is_first_content = true
      end

      attr_reader(
        :is_first_content,
      )

      attr_accessor(
        :existing_node,
        :existing_node_index,
        :new_node,
        :node_shape,
        :plan_array,
        :plan_verb,
        :previous_plan,
      )
    end
  end
end
