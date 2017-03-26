module Skylab::Snag

  class Models_::Criteria

    module Library_

      Models_ = ::Module.new

      module Models_

        class << self

          meh_h = { and: :And, or: :Or }

          define_method :class_via_symbol do | sym |
            const_get meh_h.fetch( sym ), false
          end

        end  # >>

        class Name_Value_Output_Node

          def initialize x, sym, id_x

            @associated_model_identifier = id_x
            @symbol = sym
            @value_x = x
          end

          attr_reader :associated_model_identifier, :symbol, :value_x

          def to_arguments_
            [ @value_x, @symbol ]
          end

          def to_criteria_proc_under_ model_lookup_p

            model_lookup_p[ @associated_model_identifier ].
              to_criteria_proc_out_of_( * to_arguments_ )
          end

          def to_tree_
            LIB_.basic::Tree::Immutable_Leaf.new @symbol
          end

          def criteria_tree_shape_category_
            :output_node
          end

          def modality_const
            :CriteriaTree
          end
        end

        Conjunctive_Tree__ = ::Class.new

        class And < Conjunctive_Tree__

          def symbol
            :and
          end

          def _to_criteria_proc_via_proc_array_ p_a

            last = p_a.length - 1
            -> item_x do

              d = 0
              begin
                yes = p_a.fetch( d )[ item_x ]
                yes or break
                last == d and break
                d += 1
                redo
              end while nil
              yes
            end
          end
        end

        class Or < Conjunctive_Tree__

          def symbol
            :or
          end

          def _to_criteria_proc_via_proc_array_ p_a

            last = p_a.length - 1
            -> item_x do

              d = 0
              begin
                yes = p_a.fetch( d )[ item_x ]
                yes and break
                last == d and break
                d += 1
                redo
              end while nil
              yes
            end
          end
        end

        class Conjunctive_Tree__

          def initialize a=[]
            @a = a
          end

          # ~ textual production

          def to_ascii_visualization_string_
            s = ""
            __to_ascii_visualization_line_stream.each do | s_ |
              s << s_
            end
            s
          end

          def __to_ascii_visualization_line_stream

            to_tree_.
              to_classified_stream_for( :text, :glyphset, Glyphset___[] ).
                map_by do | cx |

              "#{ cx.prefix_string }#{ cx.node.slug }#{ NEWLINE_ }"
            end
          end

          Glyphset___ = Common_.memoize do

            {     blank: '    ',
                  crook: ' •- ',
                   pipe: ' |  ',
                    tee: ' |- '
            }  # (intentionally typeable versions of [#ba-049] the tree glyphs)
          end

          def to_tree_

            me = LIB_.basic::Tree::Mutable.new symbol

            h = {}
            counter = -> k do
              if h.key? k
                h[ k ] += 1
              else
                h[ k ] = 0
              end
            end

            @a.each do | x |

              tree = x.to_tree_
              k = tree.slug
              d = counter[ k ]
              if d.nonzero?
                k = :"#{ k }[#{ d }]"
                tree = tree.new_with_slug k
              end
              me.add k, tree
            end

            me
          end

          # ~ executable criteria production

          def to_criteria_proc_under_ model_lookup_p

            _p_a = @a.map do | o |

              if :conjunction == o.criteria_tree_shape_category_

                o.to_criteria_proc_under_ model_lookup_p

              else

                _assoc_mod = model_lookup_p[ o.associated_model_identifier ]

                _assoc_mod.to_criteria_proc_out_of_( * o.to_arguments_ )
              end
            end

            _to_criteria_proc_via_proc_array_ _p_a
          end

          # ~ support & writers

          def length
            @a.length
          end

          attr_reader :a

          def push x
            @a.push x
            NIL_
          end

          def replace_last_with_ x_

            x = @a.fetch( -1 )
            @a[ -1 ] = x_
            x
          end

          def criteria_tree_shape_category_
            :conjunction
          end

          def modality_const
            :CriteriaTree
          end
        end
      end
    end
  end
end
