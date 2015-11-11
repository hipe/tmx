module Skylab::Basic

  module List

    class << self

      def build_each_pairable_via_even_iambic a
        Build_each_pairable_via_even_iambic__[ a ]
      end

      def index_of_deepest_common_element list_A_a, list_B_a

        deepest_index = nil

        [ list_A_a.length, list_B_a.length ].min.times do | d |

          if list_A_a.fetch( d ) == list_B_a.fetch( d )
            deepest_index = d
          else
            break
          end
        end

        deepest_index
      end

      def line_stream * a
        if a.length.zero?
          List_::Line_Scanner__
        else
          List_::Line_Scanner__.new( * a )
        end
      end

      def pair_stream_via_even_iambic a
        Build_pair_stream_via_even_iambic__[ a ]
      end
    end  # >>

    module Linked

      As_stream = -> node do

        p = -> do
          x = node
          node = node.next
          if ! node
            p = EMPTY_P_
          end
          x
        end

        Callback_.stream do
          p[]
        end
      end
    end

    Build_each_pairable_via_even_iambic__ = -> a do
      Callback_::Scanner.build_each_pairable_via_pair_stream_by do
        Build_pair_stream_via_even_iambic__[ a ]
      end
    end

    Build_pair_stream_via_even_iambic__ = -> a do

      Callback_::Stream.via_times( a.length / 2 ).map_by do | d |
        d <<= 1
        Callback_::Pair.via_value_and_name(
          a.fetch( d + 1 ),
          a.fetch( d ),
        )
      end
    end

    # with `build_each_pairable_via_even_iambic` produce an object
    # that responds to `each_pair` via a flat list of name-value pairs
    #
    #     ea = Home_::List.build_each_pairable_via_even_iambic [ :a, :b, :c, :d ]
    #     ::Hash[ ea.each_pair.to_a ]  # => ( { a: :b, c: :d } )

    List_ = self
  end
end
