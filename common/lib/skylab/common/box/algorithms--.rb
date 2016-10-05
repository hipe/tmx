module Skylab::Common

  class Box

    class Algorithms__ # see [#061]

      # this grain of sand is all that remains of the once vastly overwrought
      # first box class. we simplifed "box" and it moved to [cb]. this is
      # what was left that we still use and didn't classify as minimal (or
      # popular) enough to be in the main node.
      #
      # although these methods fit logically within the main node, we don't
      # want to clutter its logicspace with ours, so we put the overflow
      # into this weird facade that has the same ivars as its creator but
      # a different class.

      def initialize a, h, bx
        @a = a ; @h = h
        @bx = bx
      end

      # ~ readers that produce single entries and similar

      def if_has_name k, * p_a, & p
        p and p_a.push p
        1 == p_a.length and p_a.push EMPTY_P_
        found_p, not_found_p = p_a

        had = true
        x = @h.fetch k do
          had = false
        end
        if had
          found_p and found_p[ x ]
        else

          p = not_found_p || -> { raise ::KeyError, __say_name_not_found( k ) }

          p[ * case 1 <=> p.arity.abs
          when  0 ; [ @bx ]
          when -1 ; [ @bx, k ]
          end ]
        end
      end

      def __say_name_not_found name
        "name not found: #{ name.inspect }"
      end

      def retrieve * a, & p  # (somewhat near [#ba-015])

        # with `match_p [ <else_p>]` find first entry that matches `match_p`
        # or call `else_p`. result is value or pair per arity of `match_p`.
        # more at #storypoint-480

        p and a.push p
        match_p, else_p = a
        idx = if 2 == match_p.arity
          @a.length.times.detect do | d |
            k = @a.fetch d
            match_p[ k, @h[ k ] ]
          end
        else
          @a.length.times.detect do | d |
            match_p[ @h.fetch @a.fetch d ]
          end
        end
        if idx
          if 2 == match_p.arity
            [ @a.fetch( idx ), @h.fetch( @a.fetch idx ) ]
          else
            @h.fetch @a.fetch idx
          end
        elsif else_p
          else_p[]
        else
          raise ::KeyError, "value not found matching #<Proc@#{
            }#{ match_p.source_location.join ':' }>"  # COLON_
        end
      end

      # ~ readers that produce collections

      def to_hash
        @h.dup
      end

      # ~ mutators

      def mutate_by_sorting_name_by & p
        @a.sort_by!( & p )
        nil
      end

      # ~ destructive mutators

      def clear
        @a.clear
        @h.clear
        nil
      end

      def new_box_and_mutate_by_partition_at * sym_a
        bx = Home_::Box.new
        sym_a.each do | sym |
          bx.add(
            sym,
            if @h.key? sym
              @a[ @a.index( sym ), 1 ] = EMPTY_A_
              @h.delete sym
            end )
        end
        bx
      end

      def delete_multiple name_a

        # batch-delete, bork on key not found.

        d_a = name_a.map do |k|
          @h.fetch k  # just assert that it is there
          @a.index( k ) or raise ::KeyError, "key not found: #{ n.inspect }"
        end

        d_a.sort!.reverse!.each do | d |  # we pervertedly allow the nil key wtf
          @a[ d, 1 ] = EMPTY_A_
        end

        name_a.map do |k|
          @h.delete k
        end
      end
    end
  end
end
