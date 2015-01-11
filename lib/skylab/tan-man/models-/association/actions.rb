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
           # init_evr_for_delete  # too loud
           cc.delete_entity @argument_box, & handle_event_selectively
         end
       end
      end
    end

    class Collection_Controller__ < Model_::Document_Entity::Collection_Controller

    private

      def via_dsc_persist_entity entity, & oes_p

        did_mutate = nil

        _oes_p_ = -> * i_a, & ev_p do
          ev = ev_p[]
          if ev.ok
            case ev.terminal_channel_i
            when :created_association, :created_node
              did_mutate = true
            when :found_existing_association, :found_existing_node
            else
              raise "does '#{ ev.terminal_channel_i }' mutate the document?"  # #todo
            end
          end
          oes_p.call( * i_a ) do
            ev
          end
        end

        ok = Association_::Actors__::Mutate.with(
          :verb, :touch,
          :attrs, entity.any_parameter_value( :attrs ),
          :prototype_i, entity.any_parameter_value( :prototype ),
          :from_node_label, entity.property_value_via_symbol( :from_node_label ),
          :to_node_label, entity.property_value_via_symbol( :to_node_label ),
          :datastore, @dsc,
          :kernel, @kernel, :on_event_selectively, _oes_p_ )

        ok and flush_maybe_changed_document_to_output_adapter did_mutate
      end

      def via_dsc_delete_entity arg_box, & oes_p
        ok = Association_::Actors__::Mutate.with(
          :verb, :delete,
          :from_node_label, arg_box.fetch( :from_node_label ),
          :to_node_label, arg_box.fetch( :to_node_label ),
          :datastore, @dsc,
          :kernel, @kernel, :on_event_selectively, oes_p )

        ok and flush_changed_document_to_ouptut_adapter
      end
    end

    Association_ = self
  end
end
