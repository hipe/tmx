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

    def __transfer_the_dandy_queue
      if @dandy_queue
        ::Kernel._K
      end
      NIL
    end

    def __transfer_the_creation_tree
      ct = @creation_tree
      if ct
        Recurse__.new( @test_document_index.root_context_node, ct, @choices ).execute
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

      def initialize dest, plan_a, cx
        @choices = cx
        @destination_branch = dest  # ersatz document branch node
        @plan_array = plan_a
      end

      def execute
        @plan_array.each do |node_plan|
          send PLAN_TYPE___.fetch( node_plan.plan_type ), node_plan
        end
        NIL
      end

      PLAN_TYPE___ = {
        branch: :__wahoo_branch,
        insert_example_after_node: :__insert_example_after_node,
        place_example_in_effectively_empty_document:
          :__place_example_in_effectively_empty_document,
        replace_const_definition: :__replace_const_definition,
      }

      def __wahoo_branch bp  # branch plan
        Recurse__.new(
          bp.existing_node_index.existing_document_node,
          bp.plan_array,
          @choices,
        ).execute
        NIL
      end

      def __replace_const_definition np  # node plan
        np.existing_node.replace_lines np.new_node.to_line_stream
        NIL
      end

      def __place_example_in_effectively_empty_document node_plan
        o = @destination_branch.begin_insert_into_empty_document_given @choices
        o.example_node = node_plan.new_node
        o.finish  # nil
        NIL
      end

      def __insert_example_after_node node_plan
        prev = node_plan.previous_item_plan
        new_node = node_plan.new_node
        if prev
          _new_one_after_this = prev.new_node  # eek the *new node*
          @destination_branch.insert_example_after__ _new_one_after_this, new_node
        else
          @destination_branch.prepend_example_before_some_existing_examples__ new_node
        end
        NIL
      end
    end

    # ==
  end
end
# #history: born of pseudocode
