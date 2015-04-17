module Skylab::Snag

  module Models_::Node_Criteria

    module Library_

      Models_ = ::Module.new

      module Models_

        class << self

          meh_h = { and: :And, or: :Or }

          define_method :class_via_symbol do | sym |
            const_get meh_h.fetch( sym ), false
          end

        end  # >>

        Conjunctive_Tree__ = ::Class.new

        class And < Conjunctive_Tree__
          def symbol
            :and
          end
        end

        class Or < Conjunctive_Tree__
          def symbol
            :or
          end
        end

        class Conjunctive_Tree__

          def initialize a=[]
            @a = a
          end

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

          Glyphset___ = Callback_.memoize do

            {     blank: '    ',
                  crook: ' •- ',
                   pipe: ' |  ',
                    tee: ' |- '
            }  # (intentionally typeable versions of [#hl-172] the tree glyphs)
          end

          def to_tree_

            me = LIB_.basic::Tree.mutable_node.new symbol
            @a.each do | x |
              tree = x.to_tree_
              me.add tree.slug, tree
            end
            me
          end

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
        end
      end
    end
  end
end
