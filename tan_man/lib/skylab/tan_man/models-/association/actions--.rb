module Skylab::TanMan

  class Models_::Association  # re-opening

    edit_entity_class(

      :persist_to, :association,

      :preconditions, [ :dot_file, :node ],

      :property,
      :from_node_label,

      :property,
      :from_node_ID,

      :property,
      :to_node_label,

      :property,
      :to_node_ID )

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

      Rm = make_action_class :Delete

      class Rm

        edit_entity_class(

          :reuse, Model_::DocumentEntity.IO_properties,

          :required, :property, :from_node_label,
          :required, :property, :to_node_label )


        properties.remove Brazen_::NAME_SYMBOL  # it's ok to mutate this, yeah?


        def produce_result
          entity_collection.delete_entity(
            self, nil, & handle_event_selectively )
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
        receive_missing_required_properties_array _miss_prp_a
        UNABLE_
      end
    end

    attr_reader :has_both_labels_, :has_both_IDs_

    class Silo_Daemon < Silo_daemon_base_class_[]

      def association_collection_controller_via_preconditions bx, & oes_p

        # :+#actionless-collection-controller-experiment

        precondition_for_self :_no_action_2_,
          @silo_module.node_identifier,
          bx,
          & oes_p
      end

      def precondition_for_self action, id, bx, & oes_p
        Collection_Controller___.new action, bx, @silo_module, @kernel, & oes_p
      end
    end

    class Collection_Controller___ < Model_::DocumentEntity::Collection_Controller

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

        f_o = cc.entity_via_natural_key_fuzzily asc.property_value_via_symbol :from_node_label

        t_o = cc.entity_via_natural_key_fuzzily asc.property_value_via_symbol :to_node_label

        a = nil
        if f_o
          a = []
          a.push :from_node_label, f_o.property_value_via_symbol( :name )
        end

        if t_o
          a ||= []
          a.push :to_node_label, t_o.property_value_via_symbol( :name )
        end

        if a
          asc.via_iambic a
        end
      end

      def persist_entity bx, entity, & oes_p

        x = bx[ :attrs ]
        if x
          any_attrs_x = x  # :+[#007] should be a hash from internal call..
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

        oes_p ||= @on_event_selectively

        did_mutate = nil

        _oes_p_ = -> * i_a, & ev_p do
          ev = ev_p[]
          if ev.ok
            did_mutate = ev.did_mutate_document
          end
          oes_p.call( * i_a ) do
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

        _ok = Here_::Actors__::Mutate.call_via_iambic x_a, & _oes_p_
        _ok and Info___[ did_mutate ]
      end

      Info___ = ::Struct.new :did_mutate

      def delete_entity action, _, & oes_p

        bx = action.argument_box

        _ok = Here_::Actors__::Mutate.via(
          :verb, :delete,
          :from_node_label, bx.fetch( :from_node_label ),
          :to_node_label, bx.fetch( :to_node_label ),
          :document, document_,
          :kernel, @kernel,
          & oes_p )

        _ok and flush_changed_document_to_ouptut_adapter
      end
    end

    Here_ = self
  end
end
