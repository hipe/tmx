module Skylab::Brazen

  class Model_

    class Action_Factory__ < ::Module

      class << self

        def create_with a
          new a
        end
      end

      def initialize a
        @model_class, @cls1, @ent = a
        make_class_two
      end
    private
      def make_class_two
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

      def make i
        send :"make_#{ i }"
      end

      def make_Add
        cls = begin_class
        def cls.build_props
          @do_not_add_model_class_properties_to_action_properties ||= begin
            krnl = Entity_[].scope_kernel.new self, singleton_class
            model_class.properties.each_value do |prop|
              krnl.add_property prop
            end
            true
          end
          super
        end
        @ent[ cls, -> do
          o :flag, :property, :dry_run
          o :flag, :property, :verbose
        end ]
        cls.include Add_Methods__
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

      def make_Remove
        cls = begin_class
        @ent[ cls, -> do
          o :inflect, :verb, :with_lemma, 'remove'
          o :required, :property, NAME_
          o :flag, :property, :dry_run
          o :flag, :property, :verbose
        end ]
        cls.include Remove_Methods__
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

      module Add_Methods__

        include Semi_Generated_Instance_Methods__

        def produce_any_result_when_dependencies_are_met
          prepare_property_iambics
          @ent = self.class.model_class.new @kernel
          bc = @ent.produce_any_bound_call_edit_result_via_action_and_entity_iambics(
            @action_x_a, @model_x_a )
          if bc
            bc.receier.send bc.method_name, * bc.args
          else
            produce_any_result_when_edited_OK
          end
        end

        def receive_persisting_event ev
          @client_adapter.receive_event ev
        end
      end

      module List_Methods__

        include Semi_Generated_Instance_Methods__

        def initialize kernel
          @channel ||= :listed
          super
        end

        def produce_any_result_when_dependencies_are_met
          @scan = resolve_entity_scan
          @scan and via_scan_send_list
        end

        def receive_listed_item ev
          @client_adapter.receive_event ev
        end

      private

        def resolve_entity_scan
          _cols = infer_collections_shell
          _cols_controller = _cols.
            build_collections_controller_for_channel_and_delegate(
              :the_collections, self )
          col_controller = _cols_controller.produce_collection_controller
          col_controller and col_controller.to_property_hash_scan
        end

        def via_scan_send_list
          count = 0
          item_event = build_item_event_builder
          while h = @scan.gets
            _ev = item_event[ count, h ]
            count += 1
            send_event_structure _ev
          end
          _ev = build_success_event_with :number_of_items_found, :count, count
          _ev_ = sign_event _ev
          @client_adapter.receive_event _ev_
        end

        def build_item_event_builder
          key_a, format_h = build_black_and_white_property_formatters
          build_event_prototype_with :item,
              :offset, nil, :flyweighted_h, nil, :ok, true do |y, o|
            if o.offset.nonzero?
              y << '---'
            end
            h = o.flyweighted_h
            key_a.each do |key_s|
              y << format_h.fetch( key_s ) % h.fetch( key_s )
            end ; nil
          end
        end

        def build_black_and_white_property_formatters
          @prps = self.class.model_class.properties.to_a
          fmt = produce_property_value_format_string
          key_a = [] ; format_h = {}
          @prps.each do |prop|
            key_s = prop.name.as_lowercase_with_underscores_symbol.to_s
            key_a.push key_s
            format_h[ key_s ] = "#{ fmt % prop.name.as_human }: %s"
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

      public
        def receive_the_collection_info ev
          @client_adapter.receive_event sign_event ev
        end
        def receive_the_collection_error ev
          @client_adapter.receive_event sign_event ev
        end
      end

      module Remove_Methods__

        include Semi_Generated_Instance_Methods__

        def produce_any_result_when_dependencies_are_met
          _cols = infer_collections_shell
          _cols.delete_entity_via_action self
        end
      end

      module Semi_Generated_Instance_Methods__
      private

        def infer_collections_shell
          i_a = self.class.model_class.full_name_function.
            map( & :as_lowercase_with_underscores_symbol )
          if 1 == i_a.length
            top = @kernel.models
          elsif :data_stores_ == i_a.first  # because `Data_Stores_`
            i_a.shift
            top = @kernel.datastores
          end
          top[ i_a.first ]
        end

        def prepare_property_iambics
          model_props = self.class.model_class.properties
          scn = self.class.properties.to_scanner
          action_prop_x_a = [] ; model_prop_x_a = []
          while prop = scn.gets
            if model_props.has_name prop.name_i
              if prop.takes_argument
                model_prop_x_a.push prop.name_i,
                  instance_variable_get( prop.name.as_ivar )
              else
                model_prop_x_a.push prop.name_i
              end
            else
              action_prop_x_a.push prop.name.as_ivar,
                instance_variable_get( prop.name.as_ivar )
            end
          end
          action_prop_x_a.push :@delegate, self, :@channel, :model
          @action_x_a = action_prop_x_a ; @model_x_a = model_prop_x_a ; nil
        end

      public

        def receive_the_collections_error ev
          receive_error_event ev
        end

        def receive_model_error ev
          receive_error_event ev
        end

        def receive_model_success ev
          receive_success_event ev
        end

        def receive_model_event ev
          receive_event ev
        end

      private
        def produce_any_result_when_edited_OK
          @ent.produce_any_persist_result
        end
      end
    end
  end
end
