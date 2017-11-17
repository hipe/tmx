module Skylab::TanMan

  class Models_::Association

    class TouchOrDeleteAssociation_via_FromNode_and_ToNode___ < Common_::MagneticBySimpleModel

      def initialize

        @attrs = nil
        @prototype_name_symbol = nil
        super
      end

      def from_and_to_labels from_s, to_s
        @_is_label_based = true
        @from_node_label = from_s
        @to_node_label = to_s
        NIL
      end

      def from_and_to_IDs from_sym, to_sym
        @_is_label_based = false
        @from_node_ID = from_sym
        @to_node_ID = to_sym
        NIL
      end

      attr_writer(
        :attrs,
        :digraph_controller,
        :entity_via_element_by,
        :listener,
        :prototype_name_symbol, # was `prototype_i`
        :verb_lemma_symbol,  # `touch` | `delete`
      )

      def execute

        ok = __resolve_stmt_list_and_stream  # (B)
        ok &&= __find_nodes_if_necessary  # (C)
        ok && __work
      end

      def __work

        __find_equivalent_association_or_neighbor_associations  # (D)

        found_equivalent = remove_instance_variable :@__found_equivalent

        case @verb_lemma_symbol
        when :delete  # (E)
          if found_equivalent
            __flush_delete
          else
            __when_delete_and_association_not_found
          end
        when :touch  # (F)
          if found_equivalent
            __when_touch_and_equivalent_stmt_found
          else
            __work_when_touch
          end
        end
      end

      def __work_when_touch

        ok = __resolve_prototype  # (G)
        ok &&= __via_prototype_resolve_edge_statement  # (H)
        ok && __via_edge_statement_make_association  # (I)
      end

      # -- I

      def __via_edge_statement_make_association

        ref_x = @_least_greater_edge_stmt
        if ref_x
          @stmt_list.insert_item_before_item_ @edge_stmt, ref_x
        else
          @stmt_list.append_item_ @edge_stmt
        end

        ent = @entity_via_element_by.call @edge_stmt do |o|
          o._DO_WRITE_COLLECTION_ = true
        end

        maybe_send_event :info, :created_association do
          __build_created_association_event ent
        end

        ent
      end

      def __build_created_association_event ent

        build_OK_event_with(  # #here1 family
          :created_association,
          :association, ent,
          :did_mutate_document, true,
        ) do |y, o|
          y << "created association: #{ o.association.edge_stmt.unparse }"
        end
      end

      # -- H

      def __via_prototype_resolve_edge_statement

        edge_stmt = @_prototype.duplicate_except_(
          [ :agent, :id ],
          [ :edge_rhs, :recipient, :id ],
        )
        edge_stmt.set_source_node_id @source_node_ID_symbol
        edge_stmt.set_target_node_id @target_node_ID_symbol

        @edge_stmt = edge_stmt

        attrs = remove_instance_variable :@attrs
        if attrs
          __add_attrs_to_edge_stmt attrs
        else
          ACHIEVED_
        end
      end

      def __add_attrs_to_edge_stmt attrs

        if ! @edge_stmt[ :attr_list ]
          __add_attr_list_to_edge_stmt
        end

        @edge_stmt.attr_list.content.update_attributes_ attrs  # always succeeds?
      end

      def __add_attr_list_to_edge_stmt
        alp = @_parser.parse :a_list, 'c=d, e=f'  # attr_list proto
        ale = alp.class.new  # attr_list empty
        ale.prototype_ = alp
        atl = @_parser.parse :attr_list, '[]'
        atl[ :content ] = ale
        @edge_stmt[ :attr_list ] = atl
        NIL
      end

      # -- G

      # although not difficult per se, the effort of resolving the prototype
      # has tedious-enough level of detail to warrant at least a [#059]
      # dedicated, flowcharted algorithm to help untangle it, if not also
      # its own performer in its own file (but <100 SLOC at writing) :#here2.
      #
      # the flowchart was first derived from the code that was here, then
      # we refactored the code here to have improved flow per the chart. neat!
      #
      # as a fun aside, experimentally our "completeness" is "proven":
      #
      #   - the flowchart consists entirely of boolean branch nodes
      #     (diamonds) and terminal "conclusion" states (rectangles).
      #
      #   - every boolean branch is complete: it has a traversal for both
      #     "yes" and "no". (this point is probably tautological.)
      #
      #   - there are no cycles in the graph - every path terminates at
      #     a conclusion deterministically.
      #
      #   - every traversal in the graph (which is numbered) is associated
      #     with its corresponding code below. (find the indicators 1 thru N,
      #     all in the single method below.)
      #
      #   - (to demonstrate "true" completeness, you would want to cover-
      #     test the below method as well, and/or possibly associate the
      #     traversal identifiers with tests too.)

      def __resolve_prototype
        if __a_specific_name_of_a_prototype_is_provided
          if _document_has_prototypes  # t2
            if __resolve_prototype_via_provided_name  # t4
              _use_that_prototype  # t10
            else
              __fail_talkin_bout_cant_find_that_prototype  # t9
            end
          else
            __fail_talkin_bout_document_has_no_prototypes  # t3
          end
        elsif _document_has_prototypes  # t1
          if __resolve_prototype_via_hardcoded_name  # t6
            _use_that_prototype  # t8
          else
            _use_hardcoded_memoized_prototype  # t7
          end
        else
          _use_hardcoded_memoized_prototype  # t5
        end
      end

      def __resolve_prototype_via_provided_name  # assume both

        _ = @_named_prototypes[ @prototype_name_symbol ]
        _store :@_found_prototype, _
      end

      def __resolve_prototype_via_hardcoded_name  # assume

        _ = @_named_prototypes[ :edge_stmt ]
        _store :@_found_prototype, _
      end

      def __a_specific_name_of_a_prototype_is_provided

        @_parser = @digraph_controller.graph_sexp.class  # snuck in here CAREFUL
        @prototype_name_symbol
      end

      # ~ support (all methods used more than once)

      define_method :_use_hardcoded_memoized_prototype, -> do
        yes = true ; x = nil
        -> do
          if yes
            yes = false
            x = @_parser.parse :edge_stmt, "a -> b"  # note no `attr_list` here
            x || self._SANITY
          end
          @_prototype = x ; ACHIEVED_
        end
      end.call

      def _use_that_prototype
        @_prototype = remove_instance_variable :@_found_prototype
        ACHIEVED_
      end

      def _document_has_prototypes
        _ = @stmt_list.named_prototypes_
        _store :@_named_prototypes, _
      end

      # ~ (events for this section)

      def __fail_talkin_bout_cant_find_that_prototype
        send_error :association_prototype_not_found do
          __build_association_prototype_not_found_with_that_name
        end
      end

      def __fail_talkin_bout_document_has_no_prototypes
        send_error :association_prototypes_not_found do
          __build_association_prototypes_not_found_at_all
        end
      end

      def __build_association_prototype_not_found_with_that_name

        build_not_OK_event_with(
          :association_prototype_not_found,
          :prototype_name_symbol, @prototype_name_symbol,
        ) do |y, o|
          _ = symbol_as_identifier_ o.prototype_name_symbol
          y << "the stmt_list has no prototype named #{ _ }"
        end
      end

      def __build_association_prototypes_not_found_at_all

        build_not_OK_event_with(
          :association_prototypes_not_found,
        ) do |y, o|
          y << "the stmt_list does not have any prototypes"
        end
      end

      # -- F

      def __when_touch_and_equivalent_stmt_found

        _stmt = remove_instance_variable :@_equivalent_stmt

        ent = @entity_via_element_by.call _stmt do |o|
          o._DO_WRITE_COLLECTION_ = false  # #cov2.7 starts here
        end

        maybe_send_event :info, :found_existing_association do
          __build_found_existing_association ent
        end

        ent
      end

      def __build_found_existing_association ent

        build_OK_event_with(  # #here1 family
          :found_existing_association,
          :association, ent,
          :did_mutate_document, false,

        ) do |y, o|

          y << "found existing association: #{ o.association.edge_stmt.unparse }"
          # "assocation already exists: "
        end
      end

      # -- E

      def __when_delete_and_association_not_found

        send_error :component_not_found do

          _as_component = UnsanitizedAssociation___.new @from_node, @to_node

          ACS_[]::Events::ComponentNotFound.with(
            :component, _as_component,
            :component_association, Models_::Association,
          )
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

      def __flush_delete

        _matched_stmt = remove_instance_variable :@_equivalent_stmt
        removed_el = @stmt_list.remove_item_ _matched_stmt
        removed_el || self._SANITY

        # result is structurally like argument, but different object. we discard

        ent = @entity_via_element_by.call removed_el do |o|
          o._DO_WRITE_COLLECTION_ = true
        end

        maybe_send_event :info, :deleted_association do
          build_OK_event_with(  # #here1 family
            :deleted_association,
            :association, ent,
          )
        end

        ent
      end

      # -- D

      def __find_equivalent_association_or_neighbor_associations

        # #[#ba-045] unobtrusive lexical-esque insertion

        __init_node_ID_symbols_and_strings

        subj_source_s = @source_node_ID_string
        subj_target_s = @target_node_ID_string

        st = remove_instance_variable :@_stmt_list_stream
        begin
          stmt_list = st.gets
          stmt_list || break
          stmt = stmt_list.stmt
          if :edge_stmt != stmt.class.rule_symbol
            redo
          end

          d = subj_source_s <=> stmt.source_node_id.id2name

          if -1 == d  # subject should go before current
            least_greater_edge_stmt ||= stmt
            redo
          end

          if 1 == d  # subject should go after current
            greatest_lesser_edge_stmt = stmt
            redo
          end

          d.zero? || self._SANITY

          d = subj_target_s <=> stmt.target_node_id.id2name

          if -1 == d
            least_greater_edge_stmt ||= stmt
            redo
          end

          if 1 == d
            greatest_lesser_edge_stmt = stmt
            redo
          end

          d.zero? || self._SANITY

          found_equivalent = true
          break
        end while above

        if found_equivalent
          @__found_equivalent = true
          @_equivalent_stmt = stmt
        else
          @__found_equivalent = false
          @_least_greater_edge_stmt = least_greater_edge_stmt
          @_NOT_USED_greatest_lesser_edge_stmt = greatest_lesser_edge_stmt
        end

        NIL
      end

      def __init_node_ID_symbols_and_strings

        if @_is_label_based
          @source_node_ID_symbol = @from_node.node_identifier_symbol_
          @target_node_ID_symbol = @to_node.node_identifier_symbol_
        else
          @source_node_ID_symbol = @from_node_ID
          @target_node_ID_symbol = @to_node_ID  # (yeah, just an ivar name change)
        end

        @source_node_ID_string = @source_node_ID_symbol.id2name
        @target_node_ID_string = @target_node_ID_symbol.id2name
        NIL
      end

      # -- C

      def __find_nodes_if_necessary
        if @_is_label_based
          __find_nodes
        else
          ACHIEVED_
        end
      end

      def __find_nodes

        # :#tombstone-A.1: we used to use the nodes related-magnet directly
        # (even doing a trick with currying the performer). now we honor
        # one further level of abstraction and stay behind the "o.b" facade:

        @_nodes = Models_::Node::NodesFeatureBranchFacade_TM.new @digraph_controller

        _ok = __resolve_from_node
        _ok && __resolve_to_node
      end

      def __resolve_from_node

        _from_node = _touch_or_procure_node_via_label @from_node_label

        _store :@from_node, _from_node
      end

      def __resolve_to_node

        _to_node = _touch_or_procure_node_via_label @to_node_label

        _store :@to_node, _to_node
      end

      def _touch_or_procure_node_via_label node_label

        # when you're deleting an association (by node labels), the nodes
        # must be found (it is a retrieve (i.e procure)). however, when
        # you're touching associations, FOR NOW it's a touch!

        _m = case @verb_lemma_symbol
        when :delete ; :procure_node_via_label__
        when :touch  ; :touch_node_via_label_
        end

        _node = @_nodes.send _m, node_label, & @listener
        if _node
          _node.HELLO_NODE  # #todo
        end
        _node
      end

      # -- B

      def __resolve_stmt_list_and_stream

        if _store :@stmt_list, @digraph_controller.graph_sexp.stmt_list
          @_stmt_list_stream = @stmt_list.to_element_stream_
          ACHIEVED_
        else
          case @verb_lemma_symbol
          when :delete
            __when_no_stmt_list
          when :touch
            __init_stmt_list_and_stream_by_hacking_an_empty_thing_into_existence
            ACHIEVED_
          end
        end
      end

      def __when_no_stmt_list
        send_error :no_stmt_list do
          build_not_OK_event_with :no_stmt_list, :document, @digraph_controller
        end
        UNABLE_
      end

      def __init_stmt_list_and_stream_by_hacking_an_empty_thing_into_existence

        # we have for example an empty digraph and a `touch` verb.
        # life is easier if we hack an empty statement list into existence.
        # these do not occur in nature. we need one because touch.

        _prs = @digraph_controller.graph_sexp.class
        proto = _prs.parse :stmt_list, "a->b\nc->d\n"  # that last one..
          # the NT classes are not guaranteed to be generated yet

        sx = proto.dup
        sx.stmt = nil
        sx.tail = nil
          # we just want the empty NT parse tree, which does not occur naturaly

        sx.prototype_ = proto

        @digraph_controller.graph_sexp.stmt_list = sx
        @stmt_list = sx
        @_stmt_list_stream = sx.to_element_stream_
        NIL
      end

      # -- A

      # -- (retrofit the older code that uses these, it's fine)

      def send_error sym, & ev_p

        # (this is a made up name localized to here for now. its style it
        # out of deference to `maybe_send_event` and the others.. etc)

        @listener.call :error, sym do
          ev_p[]  # hi.
        end
        UNABLE_
      end

      def maybe_send_event * chan, & ev_p
        @listener.call( * chan ) do
          ev_p[]  # hi.
        end
        NIL
      end

      def build_not_OK_event_with * a, & p
        Common_::Event.inline_not_OK_via_mutable_iambic_and_message_proc a, p
      end

      def build_OK_event_with * a, & p
        Common_::Event.inline_OK_via_mutable_iambic_and_message_proc a, p
      end

      # ==

      class UnsanitizedAssociation___

        # represent a would-be association (#[#029] not yet associated with
        # document) so that it is compatible with [#ac-007] expressive events
        # (even though perhaps it could not be inserted into the document)

        def initialize from_node, to_node
          @from_node = from_node
          @to_node = to_node
        end

        def description_under expag

          s = "#{ @from_node.node_identifier_symbol_ } -> #{ @to_node.node_identifier_symbol_ }"
          expag.calculate do
            code s
          end
        end
      end

      # ==
      # ==
    end
  end
end
# #archive-A.3 (should be temporary) related to #open [#015] remove association
# :#history-A.2: full rewrite mostly
# :#tombstone-A.1 (can be temporary) (as referenced)
