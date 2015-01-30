module Skylab::TanMan

  class Models_::Association

    TanMan_::Entity_.call self,

        :persist_to, :association,

        :preconditions, [ :dot_file ],

        :required,
        :property,
        :from_node_label,

        :required,
        :property,
        :to_node_label

    Actions = make_action_making_actions_module

    module Actions

      Add = make_action_class :Create

      class Add

        edit_entity_class do

          o :reuse, Model_::Document_Entity.IO_properties,
            :property, :attrs,
            :property, :prototype,
            :flag, :property, :ping
        end

        def via_arguments_produce_bound_call
          if @argument_box[ :ping ]
            bound_call_for_ping
          else
            super
          end
        end
      end

      Rm = make_action_class :Delete

      class Rm

        edit_entity_class(

          :reuse, Model_::Document_Entity.IO_properties,

          :required, :property, :from_node_label,
          :required, :property, :to_node_label )

        entity_formal_property_method_names_box_for_write.
          remove Brazen_::NAME_  # ouch/meh

       def produce_result
         cc = datastore
         cc and begin
           cc.receive_delete_entity self, nil, & handle_event_selectively
         end
       end
      end
    end

    Silo__ = ::Class.new Model_::Document_Entity::Silo

    class Collection_Controller__ < Model_::Document_Entity::Collection_Controller

      def touch_association_via_node_labels src_lbl_s, dst_lbl_s, & oes_p

        oes_p ||= handle_event_selectively

        asc = Association_.edit_entity @kernel, oes_p do | o |
          o.edit_with :from_node_label, src_lbl_s,
            :to_node_label, dst_lbl_s
        end

        asc and begin
          info = _info_via_into_datastore_marshal_entity(
            nil, nil, asc, & oes_p )
          info and asc
        end
      end

      def receive_persist_entity action, entity, & oes_p

        bx = action.argument_box

        x = bx[ :attrs ]
        if x
          any_attrs_x = x  # :+[#007] should be a hash from iternal call..
            # (the front client would have to write a custom normalizer)
        end

        x = bx[ :prototype ]
        if x
          any_proto_sym = x.intern
        end

        info = _info_via_into_datastore_marshal_entity(
          any_attrs_x,
          any_proto_sym,
          entity, & oes_p )

        info and flush_maybe_changed_document_to_output_adapter__ info.did_mutate
      end

      def _info_via_into_datastore_marshal_entity any_attrs_x, any_proto_sym, entity, & oes_p  # _DOG_EAR

        @dsc ||= datastore_controller  # ick

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

        _ok = Association_::Actors__::Mutate.with(
          :verb, :touch,
          :attrs, any_attrs_x,
          :prototype_i, any_proto_sym,
          :from_node_label, entity.property_value_via_symbol( :from_node_label ),
          :to_node_label, entity.property_value_via_symbol( :to_node_label ),
          :datastore, @dsc,
          :kernel, @kernel, & _oes_p_ )

        _ok and Info___[ did_mutate ]
      end

      Info___ = ::Struct.new :did_mutate

      def via_datastore_controller_receive_delete_entity action, _, & oes_p

        bx = action.argument_box

        _ok = Association_::Actors__::Mutate.with(
          :verb, :delete,
          :from_node_label, bx.fetch( :from_node_label ),
          :to_node_label, bx.fetch( :to_node_label ),
          :datastore, @dsc,
          :kernel, @kernel,
          & oes_p )

        _ok and flush_changed_document_to_ouptut_adapter
      end
    end

    Association_ = self
  end
end
