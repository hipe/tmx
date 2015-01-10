module Skylab::Basic

  module List

    class << self

      def build_each_pairable_via_even_iambic a
        Build_each_pairable_via_even_iambic__[ a ]
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
      Callback_.stream.via_times( a.length / 2 ).map_by do |d|
        d = d << 1
        [ a.fetch( d ), a.fetch( d + 1 ) ]
      end
    end

    # with `build_each_pairable_via_even_iambic` produce an object
    # that responds to `each_pair` via a flat list of name-value pairs
    #
    #     ea = Basic_::List.build_each_pairable_via_even_iambic [ :a, :b, :c, :d ]
    #     ::Hash[ ea.each_pair.to_a ]  # => ( { a: :b, c: :d } )

    List_ = self
  end
end
