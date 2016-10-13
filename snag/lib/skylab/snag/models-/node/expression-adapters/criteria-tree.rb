module Skylab::Snag

  class Models_::Node

    module Expression_Adapters::Criteria_Tree

      class << self

        def lookup_associated_model_ const_i_a

          const_i_a.reduce Here___ do | m, const |
            m.const_get const, false
          end
        end
      end  # >>

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

      Here___ = self
    end
  end
end
