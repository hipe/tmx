module Skylab::TanMan

  class Models_::Association

    class TouchOrDeleteAssociation_via_FromNode_and_ToNode___ < Common_::MagneticBySimpleModel

      def initialize
        @_is_label_based = false  # for now, always?
        super
      end

      def from_node_label= x
        _be_label_based
        @from_node_label = x
      end

      def to_node_label= x
        _be_label_based
        @to_node_label = x
      end

      def _be_label_based
        @_is_label_based = true ; nil
      end

      attr_writer(
        :digraph_controller,
        :entity_via_element_by,
        :listener,
        :verb_lemma_symbol,  # `touch` | `delete`
      )

      if false
      xx(
       :attrs,
       :prototype_i,
      )
      end

      def execute

        @parser = @digraph_controller.graph_sexp.class

        ok = __resolve_stmt_list_and_stream

        if ok && @_is_label_based
          ok = find_nodes
        end

        ok &&= find_neighbor_associations
        ok && work

        remove_instance_variable :@result
      end

    private

      def __resolve_stmt_list_and_stream
        @stmt_list = @digraph_controller.graph_sexp.stmt_list
        if @stmt_list
          @__stmt_list_stream = @stmt_list.to_element_stream_
          ACHIEVED_
        elsif :delete == @verb_lemma_symbol
          when_no_stmt_list
        elsif :touch == @verb_lemma_symbol
          __resolve_stmt_list_and_stream_by_hacking_an_empty_thing_into_existence
        else
          self._HOLE
        end
      end

      def __resolve_stmt_list_and_stream_by_hacking_an_empty_thing_into_existence

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
        @st = sx.to_element_stream_

        ACHIEVED_
      end

      def when_no_stmt_list
        maybe_send_event :error, :no_stmt_list do
          build_not_OK_event_with :no_stmt_list, :document, @digraph_controller
        end
        @result = UNABLE_
        UNABLE_
      end

      def find_nodes

        # :#tombstone-A.1: we used to use the nodes related-magnet directly
        # (even doing a trick with currying the performer). now we honor
        # one further level of abstraction and stay behind the "o.b" facade:

        @_nodes = Models_::Node::NodesOperatorBranchFacade_TM.new @digraph_controller

        ok = __resolve_from_node
        ok &&= __resolve_to_node
        _procede_if ok
      end

      def __resolve_from_node

        _from_node = @_nodes.procure_node_via_label_ @from_node_label, & @listener

        _store :@from_node, _from_node
      end

      def __resolve_to_node

        _to_node = @_nodes.procure_node_via_label_ @to_node_label, & @listener

        _store :@to_node, _to_node
      end

      def node_verb_when_touch
        :touch
      end

      def node_verb_when_delete
        :retrieve
      end

      def find_neighbor_associations
        # :[#br-011] unobtrusive lexical-esque insertion
        @least_greater_edge_stmt = nil
        @greatest_lesser_edge_stmt = nil
        @matched_stmt = nil
        ok = ACHIEVED_

        __init_node_ID_symbols_and_strings

        snid_s = @source_node_ID_s
        tnid_s = @target_node_ID_s

        st = remove_instance_variable :@__stmt_list_stream
        begin
          stmt_list = st.gets
          stmt_list || break
          stmt = stmt_list.stmt
          if :edge_stmt != stmt.class.rule_symbol
            redo
          end

          # ~ (legacy (cleanup whenever)

            snid_s_ = stmt.source_node_id.id2name
            tnid_s_ = stmt.target_node_id.id2name
            _d = snid_s <=> snid_s_
            case _d
            when -1  # subject should go before current
              @least_greater_edge_stmt ||= stmt
            when  0
              _d_ = tnid_s <=> tnid_s_
              case _d_
              when -1 ; @least_greater_edge_stmt ||= stmt
              when  0 ; ok = when_same( stmt ) ; break
              when  1 ; @greatest_lesser_edge_stmt = stmt
              end
            when  1  # subject should go after current
              @greatest_lesser_edge_stmt = stmt
            end
          # ~ )

          redo
        end while above

        ok
      end

      def __init_node_ID_symbols_and_strings

        if @_is_label_based
          @source_node_ID_sym = @from_node.node_ID_symbol_
          @target_node_ID_sym = @to_node.node_ID_symbol_
        else
          @source_node_ID_sym = @from_node_ID
          @target_node_ID_sym = @to_node_ID  # (yeah, just an ivar name change)
        end

        @source_node_ID_s = @source_node_ID_sym.id2name
        @target_node_ID_s = @target_node_ID_sym.id2name

        nil
      end

      def when_same stmt
        send :"when_same_when_#{ @verb_lemma_symbol }", stmt
      end

      def when_same_when_touch stmt
        send_found_existing_event stmt
        @result = stmt
        UNABLE_
      end

      def when_same_when_delete stmt
        @matched_stmt = stmt
        ACHIEVED_
      end

      def send_found_existing_event stmt
        maybe_send_event :info, :found_existing_association do
          __build_found_existing_association stmt
        end
        nil
      end

      def __build_found_existing_association stmt

        build_OK_event_with :found_existing_association,

            :edge_stmt, stmt,
            :did_mutate_document, false do | y, o |

          y << "found existing association: #{ stmt.unparse }"
          # "assocation already exists: "
        end
      end

      def work
        send :"work_when_#{ @verb_lemma_symbol }"
      end

      # ~ touch

      def work_when_touch
        ok = resolve_prototype
        ok && via_prototype_make_association
      end

      def resolve_prototype
        if @prototype_i
          via_prototype_i_resolve_prototype
        else
          resolve_default_prototype
        end
      end

      def via_prototype_i_resolve_prototype
        @named_protos = @stmt_list.named_prototypes_
        if @named_protos
          via_named_protos_resolve_prototype
        else
          when_no_protos
        end
      end

      def when_no_protos
        maybe_send_event :error, :association_prototypes_not_found do
          __build_association_prototypes_not_found_at_all
        end
        @result = UNABLE_
        UNABLE_
      end

      def __build_association_prototypes_not_found_at_all
        build_not_OK_event_with :association_prototypes_not_found do |y, o|
          y << "the stmt_list does not have any prototypes"
        end
      end

      def via_named_protos_resolve_prototype
        @prototype = @named_protos[ @prototype_i ]
        if @prototype
          ACHIEVED_
        else
          when_no_proto
        end
      end

      def when_no_proto
        maybe_send_event :error, :association_prototypes_not_found do
          __build_association_prototypes_not_found_with_that_name
        end
        @result = UNABLE_
        UNABLE_
      end

      def __build_association_prototypes_not_found_with_that_name
        build_not_OK_event_with :association_prototype_not_found,
            :prototype_i, @prototype_i do |y, o|
          y << "the stmt_list has no prototype named #{ ick o.prototype_i }"
        end
      end

      def resolve_default_prototype
        np = @stmt_list.named_prototypes_
        if np
          proto = np[ :edge_stmt ]
        end
        if proto
          @prototype = proto ; ACHIEVED_
        else
          resolve_hardcoded_prototype
        end
      end

      def resolve_hardcoded_prototype
        _proto = Proto__[ @parser ]
        _store :@prototype, _proto
      end

      Proto__ = -> do
        p = -> parser do
          x = parser.parse :edge_stmt, 'a -> b'  # note no `attr_list` here
          p = -> _ { x }
          x
        end
        -> prsr do
          p[ prsr ]
        end
      end.call

      def via_prototype_make_association
        ok = resolve_edge_statement
        ok and via_edge_stmt_make_association
      end

      def resolve_edge_statement

        edge_stmt = @prototype.duplicate_except_ [ :agent, :id ],
          [ :edge_rhs, :recipient, :id ]

        edge_stmt.set_source_node_id @source_node_ID_sym
        edge_stmt.set_target_node_id @target_node_ID_sym

        @edge_stmt = edge_stmt

        if @attrs
          add_attrs_to_edge_stmt
        else
          ACHIEVED_
        end
      end

      def add_attrs_to_edge_stmt
        ok = in_edge_stmt_produce_attr_list
        ok and @edge_stmt.attr_list.content._update_attributes @attrs
      end

      def in_edge_stmt_produce_attr_list
        if @edge_stmt[ :attr_list ]
          ACHIEVED_
        else
          to_edge_stmt_add_attr_list
        end
      end

      def to_edge_stmt_add_attr_list
        alp = @parser.parse :a_list, 'c=d, e=f'  # attr_list proto
        ale = alp.class.new  # attr_list empty
        ale.prototype_ = alp
        atl = @parser.parse :attr_list, '[]'
        atl[ :content ] = ale
        @edge_stmt[ :attr_list ] = atl
        ACHIEVED_
      end

      def via_edge_stmt_make_association

        ref_x = @least_greater_edge_stmt
        if ref_x
          @stmt_list.insert_item_before_item_ @edge_stmt, ref_x
        else
          @stmt_list.append_item_ @edge_stmt
        end

        maybe_send_event :info, :created_association do
          bld_created_association_event
        end

        @result = ACHIEVED_  # is result
      end

      def __build_created_association_event
        build_OK_event_with :created_association,
            :edge_stmt, @edge_stmt,
            :did_mutate_document, true do | y, o |
          y << "created association: #{ o.edge_stmt.unparse }"
        end
      end

      # ~ delete

      def work_when_delete
        if @matched_stmt
          via_matched_stmt_work_when_delete
        else
          when_not_found
        end
      end

      def when_not_found

        @result = __maybe_send_association_not_found_event
        UNABLE_
      end

      def __maybe_send_association_not_found_event

        maybe_send_event :error, :component_not_found do

          _as_component = UnsanitizedAssociation___.new @from_node, @to_node

          ACS_[]::Events::ComponentNotFound.with(
            :component, _as_component,
            :component_association, Models_::Association,
          )
        end

        UNABLE_
      end

      def via_matched_stmt_work_when_delete

        removed_el = @stmt_list.remove_item_ @matched_stmt

        removed_el and __did_remove removed_el
      end

      def __did_remove removed_el

        # result is structurally like argument, but different object. we discard

        ent = @entity_via_element_by[ removed_el ]

        maybe_send_event :info, :deleted_association do
          build_OK_event_with :deleted_association, :association, ent
        end

        @result = ent
        NIL
      end

    if false  # #open [#015] remove association
    def destroy_all_associations node_id, _, success # i cannot fail
      res_a = each_associated_list_node( node_id ).to_a.reverse.map do |list|
        x = list._remove! list.stmt             # (reverse b/c deletes up
        x.stmt                                  # at root do a lot of juggling
      end                                       # we want to avoid. might be ok)
      res = nil
      if res_a.length.nonzero?
        res_a.reverse! # cosmetics - restore it back to the maybe lexical order
        if success
          ev = Models::Association::Events::Disassociation_Successes.new self,
            res_a
          res = success[ ev ]
        else
          res = res_a
        end
      end
      res
    end

    def each_associated_list_node node_id
      ::Enumerator.new do |y|     # used to be a nice pretty reduce but w/e
        each_edge_stmt_list.each do |edge_stmt_list|
          o = edge_stmt_list.stmt
          if o.source_node_id == node_id or o.target_node_id == node_id
            y << edge_stmt_list
          end
        end
        nil
      end
    end

    def each_edge_stmt_list       # repeats some of `prod` but w/o all the
      ::Enumerator.new do |y|     # lexcial trappings
        sl = graph_sexp.stmt_list or break
        sl.elements_.each do |stmt_list|
          stmt = stmt_list.stmt or next
          :edge_stmt == stmt.class.rule_symbol || next
          y << stmt_list
        end
        nil
      end
    end
    end

      # -- (retrofit the older code that uses these, it's fine)

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

      # --

      def _procede_if x  # experiment
        if x
          ACHIEVED_
        else
          @result = x ; x
        end
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

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

          s = "#{ @from_node.node_ID_symbol_ } -> #{ @to_node.node_ID_symbol_ }"
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
# :#tombstone-A.1 (can be temporary) (as referenced)
