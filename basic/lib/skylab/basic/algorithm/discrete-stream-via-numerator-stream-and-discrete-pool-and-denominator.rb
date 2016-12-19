module Skylab::Basic

  class Algorithm::DiscreteStream_via_NumeratorStream_and_DiscretePool_and_Denominator

    # exactly [#057]

    # synopsis
    #
    #     me = Home_::Algorithm::DiscreteStream_via_NumeratorStream_and_DiscretePool_and_Denominator
    #
    # given a stream of positive real numbers and a positive integer,
    # produce a stream of integers representing pieces of the argument
    # integer having been broken up such that the widths of the pieces
    # more or less resemble those suggested by using the real numbers
    # as ratios. what?
    #
    # so, half of six is three, right? so:
    #
    #     me.shortcut( [0.5, 0.5], 6 ).to_a  # => [ 3, 3 ]
    #
    #
    # let's break up 12 ("pixels") with this stream of ratios:
    #
    #     st = me.shortcut [0.25, 0.334, 1.0/6], 12
    #
    #       # one quarter of 12 is 3:
    #     st.gets  # => 3
    #
    #       # one third of 12 is 4:
    #     st.gets  # => 4
    #
    #       # one sixth of 12 is 2:
    #     st.gets  # => 2
    #
    #       # all done
    #     st.gets  # => nil
    #
    # note that the three produced numbers don't add up to 12. this
    # is because of what the ratios are, which don't add up to 1.
    #
    # but the main thing of this library is that when numbers are
    # rounded down, these little pieces of "spillover" add up and
    # maybe eventually pop back out.
    #
    # "spillover" is foisted on whichever item is there when the
    # accumulated amount of spillover reaches 1:
    #
    #     one_seventh = 1.0/7
    #
    #     st = me.shortcut [one_seventh, one_seventh, one_seventh], 10
    #
    #       # one seventh of 10 is about 1.4285..
    #     st.gets  # => 1
    #
    #       # again, there is 0.4285.. of "spillover"
    #     st.gets  # => 1
    #
    #       # because the total "spillover" has reached 1, pop!
    #     st.gets  # => 2

    class << self

      def shortcut f_a, pool_d

        call Stream_[ f_a ], pool_d, 1.0
      end

      def call _1, _2, _3
        new( _1, _2, _3 ).execute
      end

      alias_method :[], :call
      private :new
    end  # >>

    def initialize num_st, pool_d, denom_f
      @denominator = denom_f
      @number_stream = num_st
      @pool_integer = pool_d
    end

    def execute

      rolling_spillover = RATIONAL_ZERO___

      pixel_rational_per_user_unit =
        Rational( @pool_integer ) / Rational( @denominator )

      one = THRESHOLD__

      Common_.stream do

        f = @number_stream.gets
        if f

          pixels_rational = pixel_rational_per_user_unit * Rational( f )

          use_pixels_integer_as_rational = Rational( pixels_rational.floor )

          this_spillover = pixels_rational - use_pixels_integer_as_rational

          if this_spillover.nonzero?

            rolling_spillover += this_spillover

            if one <= rolling_spillover

              rolling_spillover -= one

              use_pixels_integer_as_rational += one
            end
          end

          use_pixels_integer_as_rational.to_i
        end
      end
    end

    # ==

    RATIONAL_ZERO___ = Rational( 0 )
    THRESHOLD__ = Rational( 1 )

    # ==
  end
end
# #tombstone: full rewrite & reconception during [tab] unification
