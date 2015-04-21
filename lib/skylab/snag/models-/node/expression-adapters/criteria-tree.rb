module Skylab::Snag

  class Models_::Node

    class Expression_Adapters::Criteria_Tree

      class << self

        def interpret_out_of_under_ tree, arg_h, kr, & oes_p

          new( arg_h, tree, kr, & oes_p ).execute
        end

        private :new
      end  # >>

      def initialize arg_h, tree, kr, & oes_p

        @arg_h = arg_h
        @on_event_selectively = oes_p
        @kernel = kr
        @tree = tree
      end

      def execute

        @collection_x = @kernel.silo( :node_collection ).
          node_collection_via_upstream_identifier(
            @arg_h.fetch( :upstream_identifier ),
            & @on_event_selectively )

        @collection_x && __via_native_collection
      end

      def __via_native_collection

        st = @collection_x.to_node_stream( & @on_event_selectively )
        st and begin

          p = @tree.to_criteria_proc_under_ method :lookup_associated_model__

          st.reduce_by do | node |
            p[ node ]
          end
        end
      end

      def lookup_associated_model__ const_i_a  # subsistence. probably won't stay.

        const_i_a.reduce CT_ do | m, const |
          m.const_get const, false
        end
      end

      module Ext_Cnt

        class << self

          def to_criteria_proc_out_of_ tree_a, sym  # :yes_or_no

            if tree_a.first  # :+#tree_a EN remanents ick
              -> node do
                ! node.has_extended_content
              end
            else
              -> node do
                node.has_extended_content
              end
            end
          end
        end  # >>
      end

      module ID_Int

        class << self

          def to_criteria_proc_out_of_ tree_a, sym

            send :"__#{ sym }__", tree_a.last  # :+#tree_a EN remanents ick
          end

          def __less_than_or_equal_to__ d
            -> node do
              d >= node.ID.to_i
            end
          end

          def __less_than__ d
            -> node do
              d > node.ID.to_i
            end
          end

          def __greater_than_or_equal_to__ d
            -> node do
              d <= node.ID.to_i
            end
          end

          def __greater_than__ d
            -> node do
              d < node.ID.to_i
            end
          end
        end  # >>
      end

      module Tags

        class << self

          def to_criteria_proc_out_of_ md, sym

            send :"__#{ sym }__", md[ :tag_stem ].intern
          end

          def __negative_tag__ tag_sym

            -> node do
              node.is_not_tagged_with tag_sym
            end
          end

          def __positive_tag__ tag_sym

            -> node do
              node.is_tagged_with tag_sym
            end
          end
        end  # >>
      end

      CT_ = self
    end
  end
end
