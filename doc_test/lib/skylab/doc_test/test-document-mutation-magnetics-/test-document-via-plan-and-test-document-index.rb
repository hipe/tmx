module Skylab::DocTest

  class TestDocumentMutationMagnetics_::TestDocument_via_Plan_and_TestDocumentIndex  # 1x

    # the final step of [#035] (barely documented)

    def initialize plan, tdi, cx, & l
      @choices = cx  # kind of bs
      @clobber_queue = plan.clobber_queue
      @creation_tree = plan.creation_tree
      @dandy_queue = plan.dandy_queue
      @_listener = l
      @plan = p
      @test_document_index = tdi
    end

    def execute
      __transfer_the_creation_tree
      __transfer_the_dandy_queue
      __transfer_the_clobber_queue
      @test_document_index.test_document
    end

    def __transfer_the_creation_tree
      ct = @creation_tree
      if ct
        _recurse ct, @test_document_index.existing_document_node, 0
      end
      NIL
    end

    def __transfer_the_dandy_queue
      dq = @dandy_queue
      if dq

        # exactly #note-1 - context nodes that exist on the right composed
        # of one or more nodes that don't yet exist on the right.

        dq.each do |plan|

          :context == plan.node_shape || self._SANITY
          :merge == plan.plan_verb || self._SANITY

          __merge_context plan
        end
      end
      NIL
    end

    def __merge_context plan

      # because of its rigid, narrow structural profile we could
      # streamline the execution of this but meh, why bother

      eni = plan.existing_node_index

      if eni.is_of_branch
        existing = eni.existing_document_node
      else
        self._THIS_CHANGED  # #todo moved #here-2
      end

      _recurse plan.plan_array, existing, 1
      NIL
    end

    def __transfer_the_clobber_queue
      cq = @clobber_queue
      if cq
        cq.each do |plan|
          send CLOBBER___.fetch( plan.plan_verb ), plan
        end
      end
      NIL
    end

    CLOBBER___ = {
      replace: :__clobber_replace,
      upgrade: :__clobber_upgrade,
    }

    def __clobber_upgrade plan

      # #coverpoint5-4 - upgrading an item node (experiment)

      _existing = plan.new_node.UPGRADE_ITEM_NODE_TO_BE_EMPTY_BRANCH_NODE(
        plan, & @_listener )

      _recurse plan.plan_array, _existing, 1
      NIL
    end

    def __clobber_replace plan
      send CLOBBER_REPLACE___.fetch( plan.node_shape ), plan
    end

    CLOBBER_REPLACE___ = {
      example: :__clobber_replace_example,
      shared_subject: :__clobber_replace_sharedsubj,
    }

    def __clobber_replace_sharedsubj plan
      _clobber_replace_item plan  # (hi.)
    end

    def __clobber_replace_example plan
      _clobber_replace_item plan  # (hi.)
    end

    def _clobber_replace_item plan
      new_node = plan.new_node
      existing_node_index = plan.existing_node_index
      # --
      _st = new_node.to_line_stream( & @_listener )
      existing_node_index.existing_child_document_node.replace_lines _st
      NIL
    end

    def _recurse plans, existing_document_node, depth_integer=0
      Recurse___.new(
        existing_document_node,
        plans,
        depth_integer,
        @choices,
        & @_listener
      ).execute
    end

    # ==

    class Recurse___

      def initialize dest, plan_a, depth, cx, & l
        @choices = cx
        @_depth = depth
        @destination_branch = dest  # ersatz document branch node
        @_listener = l
        @plan_array = plan_a
      end

      def execute
        @plan_array.each do |plan|
          send SHAPE___.fetch( plan.node_shape ), plan
        end
        NIL
      end

      SHAPE___ = {
        const_definition: :__write_const_definition,
        context: :__write_context,
        example: :__write_example,
        shared_subject: :__write_shared_subject,
      }

      def __write_context plan
        send CONTEXT___.fetch( plan.plan_verb ), plan
      end

      CONTEXT___ = {
        create: :__insert_context,
        merge: :__merge_context,
      }

      def __merge_context plan
        self._SEE  # #tombstone #here-1
      end

      def __write_const_definition plan
        send CONST_DEF__.fetch( plan.plan_verb ), plan
      end

      def __write_shared_subject plan
        send SHARED_SUBJECT___.fetch( plan.plan_verb ), plan
      end

      CONST_DEF__ = {
        create: :__insert_const_def,
        replace: :__replace_const_def,
      }

      SHARED_SUBJECT___ = {
        create: :__insert_shared_subject,
        replace: :__replace_shared_subject,
      }

      def __replace_const_def plan
        plan.existing_node.replace_lines plan.new_node.to_line_stream
        NIL
      end

      def __replace_shared_subject plan  # #not-covered
        ::Kernel._K
      end

      def __insert_const_def plan
        _insert_this_content_somewhere plan.new_node, plan
        NIL
      end

      def __insert_shared_subject plan  # #not-covoered
        _insert_this_content_somewhere plan.new_node, plan
        NIL
      end

      def __write_example plan
        send EG___.fetch( plan.plan_verb ), plan
      end

      EG___ = {
        create: :__insert_example,
        replace: :__TODO_replace_example,
      }

      def __insert_context plan

        _new_context_node = _create_this_context plan
        _insert_this_content_somewhere _new_context_node, plan
      end

      def __insert_example plan

        _insert_this_content_somewhere plan.new_node, plan
      end

      # --

      def _create_this_context plan

        # make a new context node based off the original context node in the
        # plan but only those child nodes that are in the plan

        _particular_array = plan.plan_array.map do |pl|
          pl.new_node
        end

        plan.new_node.dup_by do |o|
          o.particular_array = _particular_array
        end
      end

      def _insert_this_content_somewhere new_node, plan

        pp = plan.previous_plan
        if pp

          ref_node = pp.new_node
          ref_node ||= pp.existing_node_index.existing_document_node
          ref_node || fail

          @destination_branch.insert_after__ ref_node, new_node, & @_listener

        elsif plan.is_first_content

          if @_depth.zero?
            o = @destination_branch.begin_insert_into_empty_document @choices, & @_listener
            o.node_of_interest = new_node
            o.finish  # nil
          else
            @destination_branch.hack_insert_first_content__ new_node, & @_listener
          end

        else
          @destination_branch.prepend_before_some_existing_content__ new_node, & @_listener
        end
        NIL
      end
    end

    # ==
  end
end
# #tombstone #here-1
# #history: born of pseudocode
