module Skylab::TanMan

  module Models_::Meaning

    module HearMap

      module Definitions

        class SetMeaning

          def after
            [ :meaning, :delete_meaning ]
          end

          def definition
            [ :sequence, :functions,
                :one_or_more, :any_token,
                :keyword, 'means',
                :one_or_more, :any_token ]
          end

          def execute_via_heard hrd, & p

            ImplementationForSet___.new( p, hrd ).execute
          end
        end

        # ~

        class DeleteMeaning

          def after
            [ :association, :delete_association ]
          end

          def definition
            [ :sequence, :functions,
                :keyword, 'forget',
                :one_or_more, :any_token ]
          end

          def execute_via_heard pt, & p
            self._DO_ME
          end
        end

        # ~

        class ApplyMeaning

          def after
            [ :meaning, :delete_association ]
          end

          def definition
            [ :sequence, :functions,
                :one_or_more, :any_token,
                :keyword, 'is',
                :one_or_more, :any_token ]

          end

          def execute_via_heard hrd, & p

            ImplementationForApply___.new( p, hrd ).execute
          end
        end

        # ~

        class DeleteAssociation

          def after
            [ :association, :touch_nodes_and_create_association ]
          end

          def definition
            [ :sequence, :functions,
                :one_or_more, :any_token,
                :keyword, 'is',
                :keyword, 'not',
                :one_or_more, :any_token ]
          end

          def execute_via_heard hrd, & p
            self._DO_ME
          end
        end
      end

      # ==

      CommonImplementation__ = ::Class.new

      class ImplementationForSet___ < CommonImplementation__

        def execute

          _with_mutable_feature_branch_ do
            __via_mutable_feature_branch
          end
        end

        def __via_mutable_feature_branch

          pt = @_parse_tree_
          _value_s = pt.fetch( 2 ).join SPACE_
          _name_s = pt.fetch( 0 ).join SPACE_

          @_mutable_feature_branch_.add_meaning_by_ do |o|

            o.force_is_present = true  # because this is "set" not "create"
            o.value_string = _value_s
            o.name_string = _name_s
            o.listener = @_listener_
          end
          # (above is meaning entity on success)
        end
      end

      class ImplementationForApply___ < CommonImplementation__

        def execute
          _with_mutable_feature_branch_ do
            __via_mutable_feature_branch
          end
        end

        def __via_mutable_feature_branch

          pt = @_parse_tree_
          _node_label_s = pt.first.join SPACE_
          _meaning_name_s = pt.last.join SPACE_

          _is_dry = @_qualified_knownness_box_[ :dry_run ].value

          @_mutable_feature_branch_.into_node_apply_meaning_by_ do |o|
            o.node_label = _node_label_s
            o.meaning_name_string = _meaning_name_s
            o.is_dry = _is_dry
            o.listener = _listener_
          end

          # (result of above on success is the effected node entity)
        end
      end

      class CommonImplementation__

        def initialize p, hrd
          @_parse_tree_ = hrd.parse_tree
          @_qualified_knownness_box_ = hrd.qualified_knownness_box
          @_microservice_invocation_ = hrd.microservice_invocation
          @_listener_ = p
        end

        def _with_mutable_feature_branch_

          _with_mutable_digraph do

            @_mutable_feature_branch_ =
              Here_::MeaningsFeatureBranchFacade_.new @_mutable_digraph_

            x = yield
            remove_instance_variable :@_mutable_feature_branch_
            x
          end
        end

        define_method :_with_mutable_digraph,
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
# ( a note for #!posterity, the old treemap versions of some of these definitions were in what is now models-/hear-front/core.rb )
