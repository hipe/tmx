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

        def receive_model_error ev
          _ev_ = sign_event ev
          @client_adapter.receive_event _ev_
        end

        def receive_model_success ev
          _ev_ = sign_event ev
          @client_adapter.receive_event _ev_
        end

      private
        def when_edited_OK
          @ent.persist
        end
      end
    end
  end
end
