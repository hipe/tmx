module Skylab::TanMan

  module Models_::Meaning

    # description_ "manage meaning"

    ActionBoilerplate_ = ::Class.new

    if false
    edit_entity_class(

      :persist_to, :meaning,

      :preconditions, [ :dot_file ],

      :required,
      :ad_hoc_normalizer, -> qkn, & oes_p do
        Here_::Magnetics_::NormalizedKnownness_via_QualifiedKnownness::Name[ qkn, & oes_p ]
      end,
      :property, :name,

      :required,
      :ad_hoc_normalizer, -> qkn, & oes_p do
        Here_::Magnetics_::NormalizedKnownness_via_QualifiedKnownness::Value[ qkn, & oes_p ]
      end,
      :property, :value,
    )
    end  # if false

    module Actions

      if false
      Add = make_action_class :Create do

        edit_entity_class(
          :flag, :property, :force,
          :reuse, Model_::DocumentEntity.IO_properties )

      end
      end

      class Ls < ActionBoilerplate_

        def definition
          [
            :properties, _these_,
          ]
        end

        def execute
          __with_read_only_operator_branch_facade__ do
            @_operator_branch_.to_meaning_entity_stream_
          end
        end
      end

      if false

      Rm = make_action_class :Delete

      class Associate < Home_::Model_::DocumentEntity::Action

        Entity_.call self,

          :branch_description, -> y do
            y << "apply a meaningful tag to a node"
          end,

          :preconditions, [ :dot_file, :meaning, :node ],

          :reuse, Home_::Model_::DocumentEntity.IO_properties,
          :flag, :property, :dry_run,
          :required, :property, :meaning_name,
          :required, :property, :node_label

        def produce_result
          @meanings_controller = @preconditions.fetch :meaning
          @nodes_controller = @preconditions.fetch :node
          ok = __resolve_meaning
          ok &&= __resolve_node
          ok &&= __apply_meaning_to_node
          ok && __persist
        end

        def __resolve_meaning

          _meaning = @meanings_controller.one_entity_against_natural_key_fuzzily_ @argument_box[ :meaning_name ]
          _store :@meaning, _meaning
        end

        def __resolve_node

          _node = @nodes_controller.one_entity_against_natural_key_fuzzily_ @argument_box[ :node_label ]
          _store :@node, _node
        end

        def __apply_meaning_to_node
          @meanings_controller.apply_meaning_to_node @meaning, @node
        end

        def __persist

          @preconditions.fetch( :meaning ).
            flush_changed_document_to_output_adapter_per_action self
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
      end
      end  # if false
    end

    class ActionBoilerplate_

      def initialize
        extend Home_::Model_::CommonActionMethods
        init_action_ yield
        @_associations_ = {}
      end

      def _these_
        Home_::DocumentMagnetics_::CommonAssociations.all_
      end

      def _accept_association_ asc
        @_associations_[ asc.name_symbol ] = asc
      end

      def __with_read_only_operator_branch_facade__

        with_immutable_digraph_ do
          @_operator_branch_ = Here_::MeaningsOperatorBranchFacade_.new @_immutable_digraph_
          x = yield
          remove_instance_variable :@_operator_branch_
          x
        end
      end
    end

    Autoloader_[ self ]
    lazily :MeaningsOperatorBranchFacade_ do |c|
      const_get :Collection_Controller__
      const_defined? c, false or fail
    end

    # ==

    Here_ = self
    if false
    NAME_ = 'name'.freeze
    NEWLINE_ = "\n".freeze
    VALUE_ = 'value'.freeze
    end

    # ==
    # ==
  end
end
# #history-A: full rewrite to ween off [br]-era
