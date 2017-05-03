module Skylab::TanMan

  class Models_::Association

    # "view and edit associations"

    # (begins as entity class #here1)

    if false
    Actions__ = make_action_making_actions_module

    module Actions__

      Add = make_action_class :Create

      class Add

        edit_entity_class(
          :reuse, Model_::DocumentEntity.IO_properties,
          :property, :attrs,
          :property, :prototype,
          :flag, :property, :ping
        )

        def via_arguments_produce_bound_call
          if @argument_box[ :ping ]
            bound_call_for_ping_
          else
            super
          end
        end

        def via_edited_entity_produce_result
          asc = entity_collection._fuzzy_match_nodes_of_association @edited_entity
          if asc
            @edited_entity = asc
          end
          super
        end
      end
    end

    def normalize
      _ok = super
      _ok and __custom_normalize
    end

    def __custom_normalize

      # our true normalization at this level is imperative not declarative
      # (although it could be made to be so) however if it fails we act as
      # if it's simply labels that are required b.c ID's are corroborative

      h = @property_box.h_
      @has_both_labels_ = h[ :from_node_label ] && h[ :to_node_label ] && true
      @has_both_IDs_ = h[ :from_node_ID ] && h[ :to_node_ID ] && true

      if @has_both_labels_ || @has_both_IDs_
        ACHIEVED_
      else
        _miss_prp_a = [ :from_node_label, :to_node_label ].reduce [] do | m, i |
          if ! h[ i ]
            m.push formal_properties.fetch i
          end
          m
        end
        _receive_missing_required_associations_ _miss_prp_a
        UNABLE_
      end
    end

    attr_reader :has_both_labels_, :has_both_IDs_

    end  # if false (for the add action)

    class AssocOperatorBranchFacade_
      # was: Collection_Controller___ < Model_::DocumentEntity::Collection_Controller

      def initialize dc
        @_digraph_controller = dc
      end

      def procure_remove_association__ compound_key, & p

        _from_node_label, _to_node_label = compound_key

        Here_::TouchOrDeleteAssociation_via_FromNode_and_ToNode___.call_by do |o|

          o.from_node_label = _from_node_label
          o.to_node_label = _to_node_label

          o.entity_via_element_by = method :__entity_via_edge_stmt

          o.verb_lemma_symbol = :delete

          o.digraph_controller = @_digraph_controller
          o.listener = p
        end
      end

      if false
      def touch_association_via_node_labels src_lbl_s, dst_lbl_s, & oes_p

        oes_p ||= @on_event_selectively

        asc = _begin_association :from_node_label, src_lbl_s,
          :to_node_label, dst_lbl_s, & oes_p

        asc and begin

          asc_ = _fuzzy_match_nodes_of_association asc
          if asc_
            asc = asc_
          end

          info = _info_via_into_collection_marshal_entity(
            nil, nil, asc, & oes_p )
          info and asc
        end
      end

      def touch_association_via_IDs src_id_sym, dst_id_sym, & oes_p

        asc = _begin_association :from_node_ID, src_id_sym,
          :to_node_ID, dst_id_sym

        asc and begin

          info = _info_via_into_collection_marshal_entity(
            nil, nil, asc, & oes_p )

          info and asc
        end
      end

      def _begin_association * x_a, & oes_p

        Here_.edit_entity @kernel, ( oes_p || @on_event_selectively ) do | o |
          o.edit_via_iambic x_a
        end
      end

      def _fuzzy_match_nodes_of_association asc

        cc = @precons_box_.fetch :node

        f_o = cc.entity_via_natural_key_fuzzily asc.dereference :from_node_label

        t_o = cc.entity_via_natural_key_fuzzily asc.dereference :to_node_label

        a = nil
        if f_o
          a = []
          a.push :from_node_label, f_o.dereference( :name )
        end

        if t_o
          a ||= []
          a.push :to_node_label, t_o.dereference( :name )
        end

        if a
          asc.via_iambic a
        end
      end

      def persist_entity bx, entity, & oes_p

        x = bx[ :attrs ]
        if x
          any_attrs_x = x  # #[#007.B] should be a hash from internal call..
            # (the front client would have to write a custom normalizer)
        end

        x = bx[ :prototype ]
        if x
          any_proto_sym = x.intern
        end

        info = _info_via_into_collection_marshal_entity(
          any_attrs_x,
          any_proto_sym,
          entity, & oes_p )

        info and flush_maybe_changed_document_to_output_adapter__ info.did_mutate
      end

      def _info_via_into_collection_marshal_entity any_attrs_x, any_proto_sym, entity, & oes_p
        self._CHANGE_FO_SHO

        oes_p ||= @on_event_selectively

        did_mutate = nil

        _oes_p_ = -> * sym_a, & ev_p do
          ev = ev_p[]
          if ev.ok
            did_mutate = ev.did_mutate_document
          end
          oes_p.call( * sym_a ) do
            ev
          end
        end

        x_a = [
          :verb, :touch,
          :attrs, any_attrs_x,
          :prototype_i, any_proto_sym,
          :document, document_,
          :kernel, @kernel ]

        h = entity.properties.h_

        if entity.has_both_labels_
          x_a.push :from_node_label, h.fetch( :from_node_label ),
                   :to_node_label, h.fetch( :to_node_label )
        else
          x_a.push :from_node_ID, h.fetch( :from_node_ID ),
                   :to_node_ID, h.fetch( :to_node_ID )
        end

        _ok = Here_::TouchOrDeleteAssociation_via_FromNode_and_ToNode__.call_via_iambic x_a, & _oes_p_
        _ok and Info___[ did_mutate ]
      end

      Info___ = ::Struct.new :did_mutate
      end  # if false (for the old methods of the old collection controller)

      def __entity_via_edge_stmt edge_stmt
        Here_.new_flyweight_.reinit_as_flyweight_ edge_stmt
      end
    end

    # ==

    # ==

    class << self
      alias_method :new_flyweight_, :new
      undef_method :new
    end  # >>

    # - :#here1

      def initialize
        NOTHING_
      end

      def reinit_as_flyweight_ edge_stmt
        @edge_stmt = edge_stmt ; self
      end

      attr_reader(
        :edge_stmt,  # #testpoint - an easy copout for testing
      )

      def HELLO_ASSOCIATION  # just during development
        NOTHING_
      end

    # -

    Here_ = self
  end
end
