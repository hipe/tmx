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
          krnl = Entity_[].scope_kernel.new self, singleton_class
          model_class.properties.each_value do |prop|
            krnl.add_property prop
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

        def if_workspace_exists
          prepare_property_iambics
          @ent = self.class.model_class.new @kernel
          err = @ent.edit @action_x_a, @model_x_a
          err || when_edited_OK
        end
      end

      module List_Methods__
        include Semi_Generated_Instance_Methods__

        def if_workspace_exists
          @scan = resolve_entity_scan
          @scan and via_scan_render_list
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

        def via_scan_render_list
          count = 0
          props = self.class.model_class.properties.to_a
          d = props.reduce 0 do |m, prop|
            d_ = prop.name.as_human.length
            m < d_ ? d_ : m
          end
          fmt = "%#{ d }s"
          key_a = [] ; format_h = {}
          props.each do |prop|
            key_s = prop.name.as_lowercase_with_underscores_symbol.to_s
            key_a.push key_s
            format_h[ key_s ] = "#{ fmt % prop.name.as_human }: %s"
          end
          y = payload_output_line_yielder
          output_entity = -> h do
            count += 1
            key_a.each do |key_s|
              y << format_h.fetch( key_s ) % h.fetch( key_s )
            end
          end
          if h = @scan.gets
            output_entity[ h ]
          end
          while h = @scan.gets
            y << '---'
            output_entity[ h ]
          end
          ev = build_event_with :number_of_items_found, :count, count, :ok, true
          ev_ = sign_event ev
          @client_adapter.receive_event ev_
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

        def if_workspace_exists
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
          action_prop_x_a.push :@listener, self, :@channel, :model
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

      private
        def when_edited_OK
          @ent.persist
        end
      end
    end
  end
end
