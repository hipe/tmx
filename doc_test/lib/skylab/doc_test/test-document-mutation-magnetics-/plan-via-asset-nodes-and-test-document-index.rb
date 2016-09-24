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

        @_has_some_content_of_interest = has_some
        @branch_index = use_bi

        @clobber_queue = cq
        @dandy_queue = dq
        @listener = l
        @__particular_stream = ps
        @test_document_index = tdi
      end

      def execute

        @_creation_branch = nil  # array
        @_did_see_const_definition = false
        @_previous_plan = nil

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
        context_node: :__process_context_node,
        const_definition: :__process_const_definition,
        example_node: :__process_example_node,
        shared_subject: :__process_shared_subject,
      }

      # --
      # in the many of the guys below, we'll be taking memos to effect our
      # own branch-local version of (exactly) [#033] the fine and dandy algo
      # --

      def __process_context_node no

        ok, eni = _check_for_any_existing no
        if ok
          if eni
            __when_context_node_already_exists eni, no
          else
            __when_context_node_doesnt_already_exist no
          end
        else
          ok
        end
      end

      def __process_example_node no

        ok, eni = _check_for_any_existing no
        if ok
          if eni
            __when_example_node_already_exists eni, no
          else
            __when_example_node_doesnt_already_exist no
          end
        else
          ok
        end
      end

      def _check_for_any_existing no

        k = no.identifying_string
        if k
          eni = @test_document_index.lookup_via_identifying_string k
          if eni  # existing node index
            left_is_branch = Paraphernalia_::Is_branch[ no ]
            if left_is_branch
              if eni.is_of_branch
                [ ACHIEVED_, eni ]  # branch => branch
              else
                [ ACHIEVED_, eni ]  # item => branch ("upgrade")
              end
            elsif eni.is_of_branch
              __when_downgrade  # branch => item
            else
              [ ACHIEVED_, eni ]  # item => item
            end
          else
            ACHIEVED_
          end
        else
          self._COVER_ME__node_did_not_have_identifying_string_for_whatever_reason
          k
        end
      end

      def __when_downgrade  # #not-covered
         # when left is item and right is branch, it's a "DOWNGRADE" - can't
         @listener.call :error, :expression, :will_not_downgrade do |y|
          y << "won't downgrade from context to example - #{ k.inspect }"
          y << "(information will be lost)"
        end
        UNABLE_
      end

      def __when_context_node_already_exists eni, no

        # recurse. if empty, disregard. otherwise, add to the dandy queue.
        # remember that there are also side effects - the two queues

        creation_branch = _recurse2 no, eni
        if creation_branch
          if creation_branch.length.nonzero?
            plan = Plan__::Merge_context[ eni, creation_branch, no ]
            @_previous_plan = plan
            __add_to_dandy_queue plan
          end
          ACHIEVED_
        else
          creation_branch  # assume soft fatal
        end
      end

      def __when_context_node_doesnt_already_exist no

        # recurse. if empty, disregard. otherwise, add to creation branch.

        creation_branch = _recurse2 no
        if creation_branch
          if creation_branch.length.nonzero?
            if @_has_some_content_of_interest
              plan = Plan__::Insert_context[ no, creation_branch, @_previous_plan ]
            else
              plan = Plan__::Insert_context[ no, creation_branch, @_previous_plan ]
              plan.become_first_content
              @_has_some_content_of_interest = true
            end
            @_previous_plan = plan
            _add_to_creation_branch plan
          end
          ACHIEVED_
        else
          creation_branch  # assume soft fatal
        end
      end

      def __when_example_node_already_exists eni, no  # #coverpoint3-2

        # simply add to clobber queue. it's the only answer and the only way

        plan = Plan__::Replace_example[ no, eni, @_previous_plan ]
        @_previous_plan = plan
        _add_to_clobber_queue plan
        ACHIEVED_
      end

      def __when_example_node_doesnt_already_exist no

        if @_has_some_content_of_interest

          # #coverpoint3-1 - prepend this node before the first node in the doc
          # #coverpoint3-3 - place this node immediately after last inserted node

          plan = Plan__::Insert_example[ no, @_previous_plan ]
        else
          @_has_some_content_of_interest = true
          plan = Plan__::Insert_example[ no, @_previous_plan ]
          plan.become_first_content
        end

        @_previous_plan = plan
        _add_to_creation_branch plan
        ACHIEVED_
      end

      def _recurse2 no, branch_index=nil

        # a context node *is* a branch node (the only kind we recognize here)

        _parti_st = no.to_particular_paraphernalia_stream

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
        else
          plan = Plan__::Insert_const_def[ no, @_previous_plan ]
          if ! @_has_some_content_of_interest
            # @_has_some_content_of_interest = true  uh oh..
            plan.become_first_content
          end
        end

        @_previous_plan = plan
        _add_to_creation_branch plan
        ACHIEVED_
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
          ACHIEVED_
        else
          ::Kernel._K
          _insert_this_shared_subject pc
        end
      end

      def _insert_this_shared_subject ss
        plan = Plan__::Insert_shared_subject[ ss, @_previous_plan ]
        @_previous_plan = plan
        _add_to_creation_branch plan
        ACHIEVED_
      end

      # --

      def _add_to_creation_branch plan
        ( @_creation_branch ||= [] ).push plan ; nil
      end

      def __add_to_dandy_queue plan
        @dandy_queue.push plan ; nil
      end

      def _add_to_clobber_queue plan
        @clobber_queue.push plan ; nil
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
