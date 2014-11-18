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

          extend Entity_[].proprietor_methods  # before e.g `.bulid_props`

          class << self
            alias_method :build_action_props, :build_props
          end

          extend Semi_Generated_Module_Methods__

          define_singleton_method :model_class do _MODEL_CLASS_ end

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

          def property_method_nms_for_wrt
            began_hack or hack
            super
          end

          attr_reader :began_hack

        private

          def hack  # #open [#046] so fragile
            @began_hack = true

            krnl = Entity_[].scope_kernel.new self, singleton_class

            bx = const_get Brazen_::Entity::READ_BOX__
            bx = bx.dup
            const_set Brazen_::Entity::READ_BOX__, bx
            const_set Brazen_::Entity::WRITE_BOX__, bx  # for below

            model_class.properties.each_value do |prop|
              krnl.add_property prop
            end

            ACHIEVED_
          end
        end

        @ent[ cls, -> do
          o :flag, :property, :dry_run
          o :flag, :property, :verbose
        end ]

        cls.include Create_Methods__
        cls
      end

      def make_List
        cls = begin_class
        @ent[ cls, -> do
          o :inflect, :verb, :with_lemma, 'list', :noun, :plural
          o :flag, :property, :verbose
        end ]
        cls.include List_Methods__
        cls
      end

      def make_Delete
        cls = begin_class
        @ent[ cls, -> do
          o :inflect, :verb, :with_lemma, 'delete'
          o :required, :property, NAME_
          o :flag, :property, :dry_run
          o :flag, :property, :verbose
        end ]
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

            @parent_node.first_edit do |o|
              o.with_event_receiver self
              o.with_preconditions @preconditions
              o.with_argument_box @argument_box
            end
            @edited_entity = @parent_node ; @parent_node = nil

          else

            @edited_entity = self.class.model_class.edited self, @kernel do |o|
              o.with_preconditions @preconditions
              o.with_argument_box @argument_box
            end

          end
          PROCEDE_
        end

        def via_edited_entity_produce_any_result
          bc = @edited_entity.any_bound_call_for_edit_result
          if bc
            bc.receiver.send bc.method_name, * bc.args
          elsif @edited_entity.error_count.zero?
            via_edited_entity_produce_any_persist_result_when_edited_OK
          else
            via_edited_entity_produce_any_result_when_edited_not_OK
          end
        end
      public

        def via_edited_entity_produce_any_persist_result_when_edited_not_OK

          # typically "not OK" events were omitted, and with our result here
          # being false-ish, the client will typically use the "not OK"-ness
          # of the events to determine some final result (e.g exit status)

          UNABLE_
        end

        def via_edited_entity_produce_any_persist_result_when_edited_OK
          ok = @edited_entity.any_native_create_before_create_in_datastore
          ok && @edited_entity.produce_any_persist_result
        end

        def receive_add_related_event ev
          receive_event ev
        end
      end

      module List_Methods__

        include Semi_Generated_Instance_Methods__

        def initialize kernel
          super
          @channel ||= :listed
        end

        def produce_any_result
          ok = rslv_entity_scan
          ok && via_entity_scan_send_list
        end

      private

        def rslv_entity_scan
          @entity_scan = datastore.entity_scan_via_class self.class.model_class, self
          @entity_scan and ACHIEVED_
        end

        def via_entity_scan_send_list

          _Item_Event = make_item_event_builder
          item_index = -1

          if flyweighted_entity = @entity_scan.gets
            item_index += 1
            flyweighted_event = _Item_Event.new_mutable item_index, flyweighted_entity
            send_event flyweighted_event
          end

          while @entity_scan.gets
            item_index += 1
            flyweighted_event.replace_some_values item_index
            send_event flyweighted_event
          end

          _ev = build_OK_event_with :number_of_items_found,
            :count, ( item_index + 1 )
          _ev_ = sign_event _ev
          send_event _ev_
        end

        def make_item_event_builder

          key_i_a, format_h = build_black_and_white_property_formatters

          make_event_prototype_with :item,
              :offset, nil, :flyweighted_entity, nil, :ok, true do |y, o|

            if o.offset.nonzero?
              y << YAML_SEPARATOR__
            end

            key_i_a.each do |key_i|
              _x = o.flyweighted_entity.property_value key_i
              y << format_h.fetch( key_i ) % _x
            end ; nil
          end
        end

        YAML_SEPARATOR__ = '---'.freeze

        def build_black_and_white_property_formatters
          @prps = self.class.model_class.properties.to_a
          fmt = produce_property_value_format_string
          key_a = [] ; format_h = {}
          @prps.each do |prop|
            key_i = prop.name.as_lowercase_with_underscores_symbol
            key_a.push key_i
            format_h[ key_i ] = "#{ fmt % prop.name.as_human }: %s"
          end
          @prps = nil
          [ key_a, format_h ]
        end

        def produce_property_value_format_string
          d = @prps.reduce 0 do |m, prop|
            d_ = prop.name.as_human.length
            m < d_ ? d_ : m
          end
          "%#{ d }s"
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
          @entity_scan = @datastore_controller.entity_scan_via_class model_class, self
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
          _ev = build_neutral_event_with :single_entity_resolved_with_ambiguity,
              :model, model_class,
              :describable_source, @datastore_controller do |y, o|

            _lemma = o.model.name_function.as_human
            _source = o.describable_source.description_under self

            y << "in #{ _source } there is more than one #{ _lemma }. #{
             }using the last one."
          end

          send_event _ev

          @entity = one
          ACHIEVED_
        end

        def for_one_resolve_entity_when_had_none
          _ev = build_not_OK_event_with :entity_not_found,
              :model, model_class,
              :describable_source, @datastore_controller do |y, o|

            _lemma = o.model.name_function.as_human
            _source = o.describable_source.description_under self

            y << "in #{ _source } there are no #{ plural_noun _lemma }"
          end
          send_event _ev
          UNABLE_
        end

        def via_entity_send_one
          _ev = build_OK_event_with :entity,
              :entity, @entity, :is_completion, true do |y, o|

            y << "#{ o.entity.class.name_function.as_human } is #{
             } #{ ick o.entity.local_entity_identifier_string }"
          end
          receive_event _ev
        end
      end

      module Delete_Methods__

        include Semi_Generated_Instance_Methods__

        def produce_any_result
          init_evr_for_delete
          ok = via_evr_and_args_resolve_subject_entity
          ok &&= via_evr_and_subject_entity_prepare_for_remove
          ok && via_evr_and_subject_entity_delete_subject_entity
        end

        def via_edited_entity_produce_any_persist_result_when_edited_OK
          ok = @edited_entity.any_native_create_before_create_in_datastore
          ok && @edited_entity.produce_any_persist_result
        end

      private

        def init_evr_for_delete
          @evr = _Event.receiver.channeled.full :while_deleting_entity, self ; nil
        end

        def via_evr_and_subject_entity_delete_subject_entity
          datastore.delete_entity @subject_entity, @evr
        end

        def via_evr_and_subject_entity_prepare_for_remove
          ok = via_subject_entity_send_parameters
          ok &&= @subject_entity.any_native_delete_before_delete_in_datastore @evr
        end

        def via_subject_entity_send_parameters
          i_a = @argument_box.get_names - @subject_entity.class.properties.get_names
          @subject_entity.edit do |o|
            o.action_formal_properties = self.class.properties
            i_a.each do |i|
              o.set_arg i, @argument_box.fetch( i )
            end
          end
          PROCEDE_
        end

      public

        def receive_while_deleting_entity_method_not_implemented ev
          receive_event ev
        end

        def receive_while_deleting_entity_entity_not_found ev
          receive_event ev
        end

        def receive_while_deleting_entity_not_found ev  # #todo
          receive_event ev
        end

        def receive_while_deleting_entity_missing_force ev
          receive_event ev
        end

        def receive_while_deleting_entity_conflict ev
          receive_event ev
        end

        def receive_while_deleting_entity_pretending_for_dry_run ev
          receive_event ev
        end

        def receive_while_deleting_entity_datastore_resource_committed_changes ev
          receive_event ev
        end

        def receive_while_deleting_entity_ok ev
          receive_event ev
        end
      end

      module Semi_Generated_Instance_Methods__

      private

        def via_evr_and_args_resolve_subject_entity
          ok = via_args_resolve_identifier
          ok && via_evr_and_identifier_resolve_subject_entity
        end

        def via_args_resolve_identifier
          _name_s = @argument_box.fetch NAME_
          id = model_class.node_identifier.with_local_entity_identifier_string _name_s
          @identifier = id
          PROCEDE_
        end

        def via_evr_and_identifier_resolve_subject_entity
          datastore
          @subject_entity = @datastore.entity_via_identifier @identifier, @evr
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
