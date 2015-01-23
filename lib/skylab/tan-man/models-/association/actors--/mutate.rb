module Skylab::TanMan

  class Models_::Association

    class Actors__::Mutate

      Actor_.call self, :properties,
       :verb,  # 'touch' | 'delete'
       :attrs,
       :prototype_i,
       :from_node_label, :to_node_label,
       :datastore,
       :kernel

      def execute
        @parser = @datastore.graph_sexp.class
        ok = rslv_stmt_list_and_scan
        ok &&= find_nodes
        ok &&= find_neighbor_associations
        ok && work
        @result
      end

    private

      def rslv_stmt_list_and_scan
        @stmt_list = @datastore.graph_sexp.stmt_list
        if @stmt_list
          @scan = @stmt_list.to_stream
          ACHIEVED_
        elsif :delete == @verb
          when_no_stmt_list
        else
          self._HOLE
        end
      end

      def when_no_stmt_list
        @result = maybe_send_event :error, :no_stmt_list do
          build_not_OK_event_with :no_stmt_list, :datastore, @datastore
        end
        UNABLE_
      end

      def find_nodes

        @touch_node_p = Models_::Node.touch.curry_with(
          :verb,  send( :"node_verb_when_#{ @verb }" ),
          :datastore, @datastore,
          :kernel, @kernel,
          & @on_event_selectively )

        ok = rslv_from_node
        ok &&= rslv_to_node

        if ok
          ACHIEVED_
        else
          @result = ok
        end
      end

      def rslv_from_node
        @from_node = @touch_node_p.with :name, @from_node_label
        @from_node and ACHIEVED_
      end

      def rslv_to_node
        @to_node = @touch_node_p.with :name, @to_node_label
        @to_node and ACHIEVED_
      end

      def node_verb_when_touch
        :touch
      end

      def node_verb_when_delete
        :retrieve
      end

      def find_neighbor_associations
        @least_greater_edge_stmt = nil
        @greatest_lesser_edge_stmt = nil
        @matched_stmt = nil
        ok = ACHIEVED_
        snid_s = @from_node.node_id.id2name
        tnid_s = @to_node.node_id.id2name
        while stmt_list = @scan.gets
          stmt = stmt_list.stmt
          if :edge_stmt == stmt.class.rule
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
          end
        end
        ok
      end

      def when_same stmt
        send :"when_same_when_#{ @verb }", stmt
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
          bld_found_existing_association stmt
        end
        nil
      end

      def bld_found_existing_association stmt

        build_OK_event_with :found_existing_association,

            :edge_stmt, stmt,
            :did_mutate_document, false do | y, o |

          y << "found existing association: #{ stmt.unparse }"
          # "assocation already exists: "
        end
      end

      def work
        send :"work_when_#{ @verb }"
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
        @named_protos = @stmt_list._named_prototypes
        if @named_protos
          via_named_protos_resolve_prototype
        else
          when_no_protos
        end
      end

      def when_no_protos
        @result = maybe_send_event :error, :association_prototypes_not_found do
          bld_association_prototypes_not_found_at_all
        end
        UNABLE_
      end

      def bld_association_prototypes_not_found_at_all
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
        @result = maybe_send_event :error, :association_prototypes_not_found do
          bld_association_prototypes_not_found_with_that_name
        end
        UNABLE_
      end

      def bld_association_prototypes_not_found_with_that_name
        build_not_OK_event_with :association_prototype_not_found,
            :prototype_i, @prototype_i do |y, o|
          y << "the stmt_list has no prototype named #{ ick o.prototype_i }"
        end
      end

      def resolve_default_prototype
        np = @stmt_list._named_prototypes
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
        @prototype = Proto__[ @parser ] and ACHIEVED_
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
        edge_stmt = @prototype.__dupe(
          except: [ [ :agent, :id ], [ :edge_rhs, :recipient, :id ] ] )
        edge_stmt.set_source_node_id @from_node.node_id
        edge_stmt.set_target_node_id @to_node.node_id
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
        ale._prototype = alp
        atl = @parser.parse :attr_list, '[]'
        atl[ :content ] = ale
        @edge_stmt[ :attr_list ] = atl
        ACHIEVED_
      end

      def via_edge_stmt_make_association
        @stmt_list._insert_item_before_item @edge_stmt, @least_greater_edge_stmt  # #todo - do we need the other
        # (result is stmt_list whose stmt is the argument)
        @result = maybe_send_event :info, :created_association do
          bld_created_association_event
        end
        ACHIEVED_
      end

      def bld_created_association_event
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
        @result = maybe_send_event :error, :association_not_found do
          bld_association_no_found_event
        end
        UNABLE_
      end

      def bld_association_no_found_event
        build_not_OK_event_with :association_not_found,
            :from_node, @from_node, :to_node, @to_node do |y, o|
          _s = "#{ o.from_node.node_id } -> #{ o.to_node.node_id }"
          y << "association not found: #{ code _s }"
        end
      end

      def via_matched_stmt_work_when_delete
        removed_item = @stmt_list._remove_item @matched_stmt
        # result is structurally like argument, but different object. we discard
        if removed_item
          @result = maybe_send_event :info, :deleted_association do
            build_OK_event_with :deleted_association, :association, removed_item
          end
          nil
        else
          removed_item
        end
      end

    if false  # #todo
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
        sl._nodes.each do |stmt_list|
          stmt = stmt_list.stmt or next
          :edge_stmt == stmt.class.rule or next
          y << stmt_list
        end
        nil
      end
    end
    end
    end
  end
end
