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
            bc = resolve_document_IO_or_produce_bound_call_
            bc or super
          end
        end
      end

      Rm = make_action_class :Delete

      class Rm

        edit_entity_class do

          o :reuse, Model_::Document_Entity.IO_properties,

            :required, :property, :from_node_label,
            :required, :property, :to_node_label

          entity_formal_property_method_names_box_for_write.
            remove Brazen_::NAME_  # ouch/meh

        end

        def via_arguments_produce_bound_call
          bc = resolve_document_IO_or_produce_bound_call_
          bc or super
        end

       def produce_any_result
         cc = datastore
         cc and begin
           cc.delete_entity @argument_box, & handle_event_selectively
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
          info = _info_via_into_datastore_marshal_entity asc, & oes_p
          info and asc
        end
      end

    private

      def via_dsc_persist_entity entity, & oes_p
        info = _info_via_into_datastore_marshal_entity entity, & oes_p
        info and flush_maybe_changed_document_to_output_adapter info.did_mutate
      end

      def _info_via_into_datastore_marshal_entity entity, & oes_p

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
          :attrs, entity.any_parameter_value( :attrs ),
          :prototype_i, entity.any_parameter_value( :prototype ),
          :from_node_label, entity.property_value_via_symbol( :from_node_label ),
          :to_node_label, entity.property_value_via_symbol( :to_node_label ),
          :datastore, @dsc,
          :kernel, @kernel, & _oes_p_ )

        _ok and Info___[ did_mutate ]
      end

      Info___ = ::Struct.new :did_mutate

      def via_dsc_delete_entity arg_box, & oes_p
        _ok = Association_::Actors__::Mutate.with(
          :verb, :delete,
          :from_node_label, arg_box.fetch( :from_node_label ),
          :to_node_label, arg_box.fetch( :to_node_label ),
          :datastore, @dsc,
          :kernel, @kernel,
          & oes_p )

        _ok and flush_changed_document_to_ouptut_adapter
      end
    end

    Association_ = self
  end
end
