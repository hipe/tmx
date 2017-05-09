module Skylab::TanMan

  module Models_::Meaning

    # description_ "manage meaning"

    ActionBoilerplate_ = ::Class.new

    module Actions

      class Add < ActionBoilerplate_

        def definition
          [
            :required,
            :property, :name,

            :required,
            :property, :value,

            :properties, _these_,

            :flag, :property, :force,
            :description, -> y do
              y << "necessary to allow you to change the value of an existing meaning"
            end,
          ]
        end

        def execute
          @dry_run = nil
          with_read_write_operator_branch_facade_ do
            __via_operator_branch
          end
        end

        def __via_operator_branch

          _ent = @_operator_branch_.add_meaning_by_ do |o|

            o.value_string = remove_instance_variable :@value
            o.name_string = remove_instance_variable :@name
            o.force_is_present = remove_instance_variable :@force
            o.listener = _listener_
          end

          _ent || NIL_AS_FAILURE_
        end
      end

      class Ls < ActionBoilerplate_

        def definition
          [
            :properties, _these_,
          ]
        end

        def execute
          __with_read_only_operator_branch_facade_ do
            @_operator_branch_.to_meaning_entity_stream_
          end
        end
      end

      if false

      Rm = make_action_class :Delete

      end  # if false

      class Apply < ActionBoilerplate_

        def definition
          false and [
            :description, -> y do
              y << "apply a meaningful tag to a node"
            end,
          ]
          [

            :required,
            :property, :meaning_name,

            :required,
            :property, :node_label,

            :properties, _these_,

            :flag, :property, :dry_run,
          ]
        end

        def execute
          with_read_write_operator_branch_facade_ do
            __via_operator_branch
          end
        end

        def __via_operator_branch

          @_operator_branch_.into_node_apply_meaning_by_ do |o|
            o.node_label = @node_label
            o.meaning_name_string = @meaning_name
            o.is_dry = remove_instance_variable :@dry_run
            o.listener = _listener_
          end
        end
      end
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

      def with_read_write_operator_branch_facade_

        with_mutable_digraph_ do
          @_operator_branch_ = Here_::MeaningsOperatorBranchFacade_.new @_mutable_digraph_
          x = yield
          remove_instance_variable :@_operator_branch_
          x
        end
      end

      def __with_read_only_operator_branch_facade_

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
