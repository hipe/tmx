module Skylab::DocTest

  class TestDocumentMutationMagnetics_::TestDocument_via_Plan_and_TestDocumentIndex  # 1x

    # the final step of [#035] (barely documented)

    def initialize plan, tdi, cx, & l
      @choices = cx  # kind of bs
      @clobber_queue = plan.clobber_queue
      @creation_tree = plan.creation_tree
      @dandy_queue = plan.dandy_queue
      @NOT_USED_listener = l
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
        Recurse__.new( @test_document_index.existing_document_node, ct, @choices ).execute
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
          # (because of its rigid, narrow structural profile we could
          # streamline the execution of this but meh, why bother)
          Recurse__.new(
            plan.existing_node_index.existing_document_node,
            plan.plan_array,
            1,  # any nonzero eew
            @choices,
          ).execute
        end
      end
      NIL
    end

    def __transfer_the_clobber_queue
      cq = @clobber_queue
      if cq
        cq.each( & method( :__transfer_example ) )
      end
      NIL
    end

    def __transfer_example plan
      new_node = plan.new_node
      existing_node_index = plan.existing_node_index
      # --
      _st = new_node.to_line_stream
      existing_node_index.existing_child_document_node.replace_lines _st
      NIL
    end

    # ==

    class Recurse__

      def initialize dest, plan_a, depth=0, cx
        @choices = cx
        @_depth = depth
        @destination_branch = dest  # ersatz document branch node
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
      }

      def __write_context plan
        send CONTEXT___.fetch( plan.plan_verb ), plan
      end

      CONTEXT___ = {
        insert: :__insert_context,
        merge: :__merge_context,
      }

      def __merge_context plan
        self._REVIEW_might_be_OK
        Recurse__.new(
          plan.existing_node_index.existing_document_node,
          plan.plan_array,
          @_depth + 1,
          @choices,
        ).execute
        NIL
      end

      def __write_const_definition plan
        send CONST_DEF__.fetch( plan.plan_verb ), plan
      end

      CONST_DEF__ = {
        insert: :__TODO_insert_const_def,
        replace: :__replace_const_def,
      }

      def __replace_const_def plan
        plan.existing_node.replace_lines plan.new_node.to_line_stream
        NIL
      end

      def __write_example plan
        send EG___.fetch( plan.plan_verb ), plan
      end

      EG___ = {
        insert: :__insert_example,
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

        plan.context_node.dup_by do |o|
          o.particular_array = _particular_array
        end
      end

      def _insert_this_content_somewhere new_node, plan

        pp = plan.previous_plan
        if pp
          @destination_branch.insert_after__ pp.new_node, new_node

        elsif plan.is_first_content

          if @_depth.zero?
            o = @destination_branch.begin_insert_into_empty_document @choices
            o.node_of_interest = new_node
            o.finish  # nil
          else
            @destination_branch.hack_insert_first_content__ new_node
          end

        else
          @destination_branch.prepend_before_some_existing_content__ new_node
        end
        NIL
      end
    end

    # ==
  end
end
# #history: born of pseudocode
