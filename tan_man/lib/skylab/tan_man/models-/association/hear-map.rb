module Skylab::TanMan

  class Models_::Association

    module HearMap

      module Definitions

        class Touch_Nodes_And_Create_Association

          def after
            # nothing.
          end

          def definition
            [ :sequence, :functions,
                :one_or_more, :any_token,
                :keyword, 'depends',
                :keyword, 'on',
                :one_or_more, :any_token ]
          end

          def execute_via_heard hrd, & p

            pt = hrd.parse_tree

            _source_node_label = pt.fetch( 0 ).join SPACE_
            _target_node_label = pt.fetch( 3 ).join SPACE_

            TouchNodes_and_CreateAssociation_via___.call_by do |o|
              o.source_node_label = _source_node_label
              o.target_node_label = _target_node_label
              o._qualified_knownness_box_ = hrd.qualified_knownness_box
              o._microservice_invocation_ = hrd.microservice_invocation
              o._listener_ = p
            end
          end
        end

        class Delete_Association

          def after
            [ :meaning, :apply_meaning ]
          end

          def definition
            [ :sequence, :functions,
                :one_or_more, :any_token,
                :keyword, 'does',
                :keyword, 'not',
                :keyword, 'depend',
                :keyword, 'on',
                :one_or_more, :any_token ]
          end

          def execute_via_heard hrd
            self._DO_ME
          end
        end
      end

      # ==

      class TouchNodes_and_CreateAssociation_via___ < Common_::MagneticBySimpleModel

        def initialize
          super  # hi.
        end

        attr_writer(
          :_listener_,
          :_microservice_invocation_,
          :_qualified_knownness_box_,
          :source_node_label,
          :target_node_label,
        )

        def execute
          with_mutable_digraph_ do
            __via_mutable_digraph
          end
        end

        def __via_mutable_digraph

          _oper = Models_::Association::AssocOperatorBranchFacade_TM.new @_mutable_digraph_

          _ent = _oper.touch_association_by_ do |o|

            o.attrs = NOTHING_  # hi.
            o.prototype_name_symbol = NOTHING_  # hi.

            o.from_and_to_labels(
              remove_instance_variable( :@source_node_label ),
              remove_instance_variable( :@target_node_label ),
            )

            o.listener = @_listener_
          end

          if _ent
            _ent.HELLO_ASSOCIATION
          end
          _ent
        end

        define_method :with_mutable_digraph_,
          Models_::Hear::DEFINITION_FOR_THE_METHOD_CALLED_WITH_MUTABLE_DIGRAPH

        attr_reader(
          :_listener_,
        )
      end

      # ==
      # ==
    end
  end
end
# #history-A.1: half-rewrite during ween off [br] to integrate with new operator branch facades
# ( a note for #!posterity, the old treemap versions of some of these definitions were in what is now models-/hear-front/core.rb )
