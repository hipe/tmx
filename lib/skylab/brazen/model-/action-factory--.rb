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
          o :required, :property, :name
          o :flag, :property, :dry_run
          o :flag, :property, :verbose
        end ]
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
    end
  end
end
