module Skylab::Basic

  module Tree

    class Magnetics::ClassifiedStream_via_Tree < Common_::Actor::Monadic  # :[#053]

      def initialize node
        @node = node
      end

      def execute

        p = nil
        recurse = -> node_a, depth, next_p do  # assume nonzero length

          d = 0
          last = node_a.length - 1

          p = -> do

            node = node_a.fetch d

            _is_first = d.zero?
            is_last = last == d

            x = Classifications___.new node, _is_first, is_last, depth

            d += 1

            if node.has_children

              _next_p_ = if is_last
                next_p
              else
                p  # stay
              end

              _node_a_ = node.to_child_stream.to_a

              recurse[ _node_a_, depth + 1, _next_p_ ]

            elsif is_last

              p = next_p
            end

            x
          end

          nil
        end

        recurse[ [ @node ], 0, EMPTY_P_ ]

        Common_.stream do
          p[]
        end
      end

      Classifications___ = ::Struct.new :node, :is_first, :is_last, :depth
    end
  end
end
