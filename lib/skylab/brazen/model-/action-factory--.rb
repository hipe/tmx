module Skylab::Brazen

  class Model_

    class Action_Factory__ < ::Module

      class << self

        def make *a
          new do
            init_via_model_action_entity( * a )
          end
        end

        def retrieve_methods
          Retrieve_Methods__
        end
      end

      def initialize & p
        instance_exec( & p )
      end

    private

      def init_via_model_action_entity m_cls, a_cls, e_cls
        @model_class = m_cls ; @cls1 = a_cls ; @ent = e_cls
        resolve_cls2
      end

      def resolve_cls2

        @cls2 = const_set :Semi_Generated_Action, ::Class.new( @cls1 )

        _MODEL_CLASS_ = @model_class

        @cls2.class_exec do

          extend Brazen_::Entity::Common_Module_Methods_  # before next line

          class << self
            alias_method :build_action_props, :build_immutable_properties_stream_with_random_access_
          end

          extend Semi_Generated_Module_Methods__

          define_singleton_method :model_class do
            _MODEL_CLASS_
          end

        end ; nil
      end

    public

      def make_actions_module
        mod = ::Module.new
        _FACTORY_ = self
        mod.define_singleton_method :make_action_class do |i, & p|
          _FACTORY_.make_action_class_via_name_and_proc i, p
        end
        mod
      end

      def make_action_class_via_name_and_proc i, p
        cls = send :"make_#{ i }"
        p and cls.class_exec( & p )
        cls
      end

    private

      def make_Create

        cls = begin_class

        class << cls

          def entity_formal_property_method_names_box_for_write

            # [#046] this is much improved from what it had been but could
            # still be improved: the first time we go to write our own
            # properties, experimentally grab ALL of the properties of our
            # model class and glom them as if they are ours (this is the
            # beauty of immutable properties. you can just).

            if hack_grab_mutex
              super
            else
              @hack_grab_mutex = true
              x = super
              _hack_grab_props  # WARNING this method calls the current one
              x
            end
          end

          attr_reader :hack_grab_mutex

          private def _hack_grab_props
            ( edit_entity_class do |sess|
              model_class.properties.each_value do | pr |
                sess.receive_property pr
              end
            end )
            nil
          end
        end

        @ent.call cls do
          o :flag, :property, :dry_run
          o :flag, :property, :verbose
        end

        cls.include Create_Methods__
        cls
      end

      def make_List
        cls = begin_class
        @ent.call cls do
          o :inflect, :verb, :with_lemma, 'list', :noun, :plural
          o :flag, :property, :verbose
        end
        cls.include List_Methods__
        cls
      end

      def make_Delete
        cls = begin_class
        @ent.call cls do
          o :inflect, :verb, :with_lemma, 'delete'
          o :required, :property, NAME_
          o :flag, :property, :dry_run
          o :flag, :property, :verbose
        end
        cls.include Delete_Methods__
        cls
      end

    private

      def begin_class
        ::Class.new @cls2
      end

      module Semi_Generated_Module_Methods__

        def has_description
          true
        end

        def description_block
          cls = self
          -> y do
            nf = cls.name_function
            y << "#{ nf.inflected_verb } #{ nf.inflected_noun }"
          end
        end
      end

      Semi_Generated_Instance_Methods__ = ::Module.new

      module Create_Methods__

        include Semi_Generated_Instance_Methods__

        def produce_any_result
          ok = resolve_edited_entity
          ok && via_edited_entity_produce_any_result
        end

      private

        def resolve_edited_entity
          via_argument_box_resolve_edited_entity
        end

        def via_argument_box_resolve_edited_entity

          if @parent_node

            # experimentally, the child action "takes over" the parent

            @parent_node.first_edit do | o |
              o.replace_selective_event_listener_via_channel_proc @__HESVC_p__
              o.preconditions @preconditions
              o.argument_box @argument_box
            end
            @edited_entity = @parent_node
            @parent_node = nil

          else

            @edited_entity = self.class.model_class.
                  edited @kernel, handle_event_selectively do |o|
              o.preconditions @preconditions
              o.argument_box @argument_box
            end
          end

          PROCEDE_
        end

        def via_edited_entity_produce_any_result
          bc = @edited_entity.any_bound_call_for_edit_result
          if bc
            bc.receiver.send bc.method_name, * bc.args
          else
            via_edited_entity_produce_any_persist_result_when_edited_OK
          end
        end

      public

        def via_edited_entity_produce_any_persist_result_when_edited_OK
          ok = @edited_entity.any_native_create_before_create_in_datastore
          ok && @edited_entity.produce_any_persist_result
        end
      end

      module List_Methods__

        include Semi_Generated_Instance_Methods__

        def produce_any_result
          datastore.entity_stream_via_model(
            self.class.model_class, & handle_event_selectively )
        end
      end

      module Retrieve_Methods__

        include Semi_Generated_Instance_Methods__

      private

        def send_one_entity
          @datastore_controller = datastore.datastore_controller
          @datastore_controller and begin
            ok = via_dsc_for_one_resolve_entity
            ok and via_entity_send_one
          end
        end

        def via_dsc_for_one_resolve_entity
          @entity_scan = @datastore_controller.entity_stream_via_model(
            model_class, & handle_event_selectively )
          via_entity_scan_and_dsc_for_one_resolve_entity
        end

        def via_entity_scan_and_dsc_for_one_resolve_entity
          one = @entity_scan.gets
          if one
            x = @entity_scan.gets
            if x
              had_many = true
              one = x
            end
            while x = @entity_scan.gets
              one = x
            end
            if had_many
              via_dsc_for_one_resolve_entity_when_had_many_via_last one
            else
              @entity = one
              ACHIEVED_
            end
          else
            for_one_resolve_entity_when_had_none
          end
        end

        def via_dsc_for_one_resolve_entity_when_had_many_via_last one
          maybe_send_event :info, :single_entity_resolved_with_ambiguity do
            bld_single_entity_resolved_with_ambiguity
          end
          @entity = one
          ACHIEVED_
        end

        def bld_single_entity_resolved_with_ambiguity
          build_neutral_event_with :single_entity_resolved_with_ambiguity,
              :model, model_class,
              :describable_source, @datastore_controller do |y, o|

            _lemma = o.model.name_function.as_human
            _source = o.describable_source.description_under self

            y << "in #{ _source } there is more than one #{ _lemma }. #{
             }using the last one."
          end
        end

        def for_one_resolve_entity_when_had_none
          maybe_send_event :error, :entity_not_found do
            bld_entity_not_found_event
          end
          UNABLE_
        end

        def bld_entity_not_found_event
          build_not_OK_event_with :entity_not_found,
              :model, model_class,
              :describable_source, @datastore_controller do |y, o|

            _lemma = o.model.name_function.as_human
            _source = o.describable_source.description_under self

            y << "in #{ _source } there are no #{ plural_noun _lemma }"
          end
        end

        def via_entity_send_one
          maybe_send_event :payload do
            bld_single_entity_resolved_without_ambiguity
          end
        end

        def bld_single_entity_resolved_without_ambiguity
          build_OK_event_with :entity,
              :entity, @entity, :is_completion, true do |y, o|

            y << "#{ o.entity.class.name_function.as_human } is #{
             } #{ ick o.entity.local_entity_identifier_string }"
          end
        end
      end

      module Delete_Methods__

        include Semi_Generated_Instance_Methods__

        def produce_any_result
          init_selective_listener_proc_for_delete
          ok = via_OES_and_args_resolve_subject_entity
          ok &&= via_OES_and_subject_entity_prepare_for_remove
          ok && via_OES_and_subject_entity_delete_subject_entity
        end

        def via_edited_entity_produce_any_persist_result_when_edited_OK
          ok = @edited_entity.any_native_create_before_create_in_datastore
          ok && @edited_entity.produce_any_persist_result
        end

      private

        def init_selective_listener_proc_for_delete
          @on_event_selectively = event_lib.
            produce_handle_event_selectively_through_methods.
              full self, :while_deleting_entity do | * i_a, & ev_p |
            maybe_receive_event_via_channel i_a, & ev_p
          end
        end

        def via_OES_and_subject_entity_delete_subject_entity
          datastore.delete_entity @subject_entity, & handle_event_selectively
        end

        def via_OES_and_subject_entity_prepare_for_remove
          ok = via_subject_entity_send_parameters
          ok &&= @subject_entity.any_native_delete_before_delete_in_datastore(
            & handle_event_selectively )
        end

        def via_subject_entity_send_parameters
          i_a = @argument_box.get_names - @subject_entity.formal_properties.get_names
          @subject_entity.edit do |o|
            o.action_formal_props formal_properties
            i_a.each do |i|
              o.set_arg i, @argument_box.fetch( i )
            end
          end
          PROCEDE_
        end
      end

      module Semi_Generated_Instance_Methods__

      private

        def via_OES_and_args_resolve_subject_entity
          ok = via_args_resolve_identifier
          ok && via_OES_and_identifier_resolve_subject_entity
        end

        def via_args_resolve_identifier
          _name_s = @argument_box.fetch NAME_
          id = model_class.node_identifier.with_local_entity_identifier_string _name_s
          @identifier = id
          PROCEDE_
        end

        def via_OES_and_identifier_resolve_subject_entity
          datastore
          @subject_entity = @datastore.entity_via_identifier @identifier, & handle_event_selectively
          @subject_entity ? PROCEDE_ : UNABLE_
        end

        def datastore
          @datastore ||= prdc_ds
        end

        def prdc_ds
          @preconditions.fetch self.class.model_class.persist_to.full_name_i
        end

        def model_class
          self.class.model_class
        end
      end
    end
  end
end
