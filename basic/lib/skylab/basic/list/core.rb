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

      def pairs_scan_via_even_iambic a
        Build_pairs_scan_via_even_iambic__[ a ]
      end
    end

    Build_each_pairable_via_even_iambic__ = -> a do
      Callback_::Scanner.build_each_pairable_via_pairs_stream_proc do
        Build_pairs_scan_via_even_iambic__[ a ]
      end
    end

    Build_pairs_scan_via_even_iambic__ = -> a do
      Callback_::Stream.via_times( a.length / 2 ).map_by do |d|
        d = d << 1
        [ a.fetch( d ), a.fetch( d + 1 ) ]
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