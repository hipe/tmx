module Skylab::TanMan

  class Models_::Association

    Brazen_::Model_::Entity[ self, -> do

      o :persist_to, :association,

        :preconditions, [ :dot_file ],

        :required,
        :property,
        :from_node_label,

        :required,
        :property,
        :to_node_label

    end ]

    class << self

      remove_method :get_unbound_lower_action_scan

      alias_method :get_unbound_lower_action_scan, :orig_gulas

    end

    Actions = make_action_making_actions_module

    module Actions

      Add = make_action_class :Create

      class Add

        Model_::Entity[ self, -> do

          o :reuse, Model_::Document_Entity.IO_properties,
            :property, :attrs,
            :property, :prototype,
            :flag, :property, :ping

        end ]

        def via_arguments_produce_bound_call
          if @argument_box[ :ping ]
            bound_call_for_ping
          else
            bc = any_bound_call_for_resolve_document_IO
            bc or super
          end
        end
      end

      Rm = make_action_class :Delete

      class Rm

        Model_::Entity[ self, -> do

          o :reuse, Model_::Document_Entity.IO_properties

          property_method_nms_for_wrt.remove Brazen_::NAME_  # ouch/meh

          o :required, :property, :from_node_label,
            :required, :property, :to_node_label

        end ]

        def via_arguments_produce_bound_call
          bc = any_bound_call_for_resolve_document_IO
          bc or super
        end

       def produce_any_result
         cc = datastore
         cc and begin
           # init_evr_for_delete  # too loud
           cc.delete_entity @argument_box, self
         end
       end
      end
    end

    class Collection_Controller__ < Model_::Document_Entity::Collection_Controller

    private

      def via_dsc_persist_entity entity, evr
        did_mutate = nil
        _evr_ = Event_[].receiver.map_reduce evr do |ev|
          if ev.ok
            case ev.terminal_channel_i
            when :created_association ; did_mutate = true
            when :created_node ; did_mutate = true
            when :found_existing_association
            when :found_existing_node
            else ; raise "self._DO_ME: does or does not '#{ ev.terminal_channel_i }' mutate the document?"
            end
          end
          ev
        end

        ok = Association_::Actors__::Mutate.with(
          :verb, :touch,
          :attrs, entity.any_parameter_value( :attrs ),
          :prototype_i, entity.any_parameter_value( :prototype ),
          :from_node_label, entity.property_value( :from_node_label ),
          :to_node_label, entity.property_value( :to_node_label ),
          :datastore, @dsc,
          :event_receiver, _evr_, :kernel, @kernel )

        ok and flush_maybe_changed_document_to_output_adapter did_mutate
      end

      def via_dsc_delete_entity arg_box, evr
        ok = Association_::Actors__::Mutate.with(
          :verb, :delete,
          :from_node_label, arg_box.fetch( :from_node_label ),
          :to_node_label, arg_box.fetch( :to_node_label ),
          :datastore, @dsc,
          :event_receiver, evr, :kernel, @kernel )

        ok and flush_changed_document_to_ouptut_adapter
      end
    end

    Association_ = self
  end
end
