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
      br = BooleanReference___.new
      if @test_document_index.branch_index.node_indexes_of_interest.length.nonzero?
        br.become_true
      end
      @has_some_context_or_examples_boolean_reference = br
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

      _ = Recurse__.into_for _st, self
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
      :has_some_context_or_examples_boolean_reference,
      :listener,
      :test_document_index,
    )

    # ==

    class Recurse__

      # because it's algorithmically convenient, result is a possibly zero-
      # length array representing the creation tree, whereas the other two
      # target structures (queues) are written to via mutate-in-place
      # arguments. IFF soft fatal error, result will instead be false-ish.

      class << self
        def into_for particular_stream, args
          new(
            args.clobber_queue,
            args.dandy_queue,
            particular_stream,
            args.has_some_context_or_examples_boolean_reference,
            args.test_document_index,
            & args.listener
          ).execute
        end
        private :new
      end  # >>

      def initialize cq, dq, ps, br, tdi, & l
        @clobber_queue = cq
        @dandy_queue = dq
        @has_some_context_or_examples_boolean_reference = br
        @listener = l
        @__particular_stream = ps
        @test_document_index = tdi
      end

      def execute

        @_creation_branch = nil  # array
        @_did_see_const_definition = false
        @_previous_item_plan = nil

        ok = ACHIEVED_
        st = remove_instance_variable :@__particular_stream
        begin
          no = st.gets
          no || break
          ok = send SHAPE___.fetch( no.paraphernalia_category_symbol ), no
          ok || break
          redo
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
        const_definition_shared_setup: :__process_const_definition_shared_setup,
        example_node: :__process_example_node,
        shared_subject_shared_setup: :__PROCESS_SHARED_SUBJECT_SHARED_SETUP,
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
            _left_is_branch = IS_BRANCH___.fetch no.paraphernalia_category_symbol
            if eni.is_branch == _left_is_branch
              [ ACHIEVED_, eni ]
            else
              self._COVER_ME_node_changed_shape_fun
            end
          else
            ACHIEVED_
          end
        else
          self._COVER_ME__node_did_not_have_identifying_string_for_whatever_reason
          k
        end
      end

      IS_BRANCH___ = {
        context_node: true,
        example_node: false,
      }

      def __when_context_node_already_exists eni, no

        # recurse. if empty, disregard. otherwise, add to the dandy tree.
        # remember that there are also side effects - the two queues

        creation_branch = _recurse no
        if creation_branch
          if creation_branch.length.nonzero?
            self._xx
            _bp = BranchPlan___.new creation_branch, eni
            ( @_creation_branch ||= [] ).push _bp
          end
          ACHIEVED_
        else
          creation_branch  # assume soft fatal
        end
      end

      def __when_context_node_doesnt_already_exist no

        ::Kernel._K_readme_fun_plainish_and_simplesque
        # recurse. if empty, disregard. otherwise, add to creation tree.
        ACHIEVED_
      end

      def __when_example_node_already_exists eni, no  # #coverpoint3-2

        # simply add to clobber queue. it's the only answer and the only way

        plan = ReplaceExample___.new no, eni, @_previous_item_plan
        @_previous_item_plan = plan
        @clobber_queue.push plan
        ACHIEVED_
      end

      def __when_example_node_doesnt_already_exist no

        plan = if @has_some_context_or_examples_boolean_reference.value

          # #coverpoint3-1 - prepend this node before the first node in the doc
          # #coverpoint3-3 - place this node immediately after last inserted node

          InsertExampleAfterNode___.new no, @_previous_item_plan
        else
          @has_some_context_or_examples_boolean_reference.become_true
          PlaceExampleInEffectivelyEmptyDocument___.new no
        end

        @_previous_item_plan = plan
        ( @_creation_branch ||= [] ).push plan
        ACHIEVED_
      end

      def _recurse no

        # a context node *is* a branch node (the only kind we recognize here)

        _parti_st = no.to_particular_paraphernalia_stream

        self.class.into_for _parti_st, self
      end

      def __process_const_definition_shared_setup no
        if @_did_see_const_definition
          self._COVER_ME_MULTIPLE_const_definitionS
        else
          @_did_see_const_definition = true
          __do_process_const_definition_shared_setup no
        end
      end

      def __do_process_const_definition_shared_setup no

        plan = TouchConstDefinition___.new no, @_previous_item_plan
        plan = @_previous_item_plan
        ( @_creation_branch || [] ).push plan
        ACHIEVED_
      end

      attr_reader(
        :clobber_queue,
        :dandy_queue,
        :has_some_context_or_examples_boolean_reference,
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

    class BranchPlan___

      def initialize a, eni
        self._NEEDS_MORE_probably
        @_a = a
        @_existing_node_index = eni
      end
    end

    TouchConstDefinition___ = ::Struct.new :new_node, :previous_item_plan do
      def plan_type
        :touch_const_definition
      end
    end

    ReplaceExample___ = ::Struct.new :new_node, :existing_node_index, :previous_item_plan do
      def plan_type
        :replace_example
      end
    end

    InsertExampleAfterNode___ = ::Struct.new :new_node, :previous_item_plan do
      def plan_type
        :insert_example_after_node
      end
    end

    PlaceExampleInEffectivelyEmptyDocument___ = ::Struct.new :new_node do
      def plan_type
        :place_example_in_effectively_empty_document
      end
    end

    # ==

    class BooleanReference___
      def initialize
        @value = false
      end
      def become_true
        @value = true ; nil
      end
      attr_reader(
        :value,
      )
    end
  end
end
