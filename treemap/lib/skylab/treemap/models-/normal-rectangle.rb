module Skylab::Treemap

  class Models_::NormalRectangle

    # all values are rationals for now..

    # -
      def initialize x, y, w, hi, thx

        @has_zero_volume = w.zero? || hi.zero?

        @x = Rational( x )
        @y = Rational( y )
        @width = Rational( w )
        @height = Rational( hi )
        @__threshold = thx
      end

      # each of the below two methods is called with a "weight" representing
      # the total weight of all the items to be rendered, i.e the would-be
      # weight of the receiver rectangle. one such method call produces a
      # proc that when called produces each next sub-rectangle. in these
      # calls you send to the proc the weight of the individual item to be
      # rendered and it produces a representative sub-rectangle.
      #
      #             +-------------------------------------+
      #             |                                     |
      #             +-------------------------------------+
      #               let's say this big rect weighs "12"
      #
      #     the_proc = big_rect.one_of_these_methods 12
      #
      # with the proc produced by the method, with each next call to it you
      # pass it each next weight to be represented by a sub-rectangle and
      # in this way each next sub-rectangle is produced. the significant
      # dimension (width or height) of each produced sub-rectangle is
      # proportional to the involved numbers. (more specifically, the width
      # (or height) of the produced rectangle is some function of these
      # three values:
      #   - the weight of that item
      #   - the weight of the big rectangle (i.e of all items)
      #   - the width (or height) of the the big rectangle.)
      #
      # so here's three successive calls to the produced fuction:
      #
      #     the_proc[ 3 ]  # =>
      #             +-------+
      #             |       |
      #             +-------+
      #
      #     the_proc[ 6 ]  # =>
      #                      +----------------+
      #                      |                |
      #                      +----------------+
      #
      #     the_proc[ 1 ]  # =>
      #                                        +--+
      #                                        |  |
      #                                        +--+
      #
      # successive calls to the proc will result in successive adjacent
      # sub-rectangles along whatever axis makes sense to be chosen given
      # the receiver's aspect ratio and "threshold". not only is the width
      # (or height) of each next sub-rectangle determined in this way, but
      # also its x (or y).
      #
      # if this were all there was to it then it would be hypothetically
      # possible to overrun the imaginary "end" of the big rectangle quite
      # plainly with any N number of calls to the proc. but there's more to
      # it.
      #
      # for purposes of pixelation, we need to know when the sub-rectangle
      # being produce is the "last" subrectangle in the series, i.e the one
      # that should land flush with the edge of the big rectangle.
      # (in the future we might use [#ba-057] the "spillover" algorithm
      # for this but we're playing it safe and simple for now..)
      #
      # as such, if you call the produced proc "too many" times, what
      # happens is undefined (i.e not covered, and unknown).

      def flush_sequential_spatial_distributor_for_zero_weight__ num_buckets
        _same true, num_buckets
      end

      def flush_sequential_spatial_distributor_for_nonzero_weight__ weight, num_buckets
        _same false, weight, num_buckets
      end

      def _same is_zero, weight=nil, num_bux

        thx = remove_instance_variable :@__threshold
        _actual = @height / @width
        _is_portrait = thx <= _actual

        if _is_portrait
          __build_horizontal_sequential_subdivider is_zero, weight, num_bux, thx
        else
          __build_vertical_sequential_subdivider is_zero, weight, num_bux, thx
        end
      end

      def __build_vertical_sequential_subdivider is_zero, weight, num_bux, thx

        # "vertical" refers to the axis along which the imaginary blade
        # moves when it slices the rectagle, so the rect is probably wide.

        if is_zero
          zero_rational = Rational( 0 )
          width_share_via = -> _wght do
            zero_rational
          end
        else
          weight_rational = Rational( weight )
          width_share_via = -> wght do
            Rational( wght ) / weight_rational
          end
        end

        current_x = @x
        last_additional_width = nil

        -> bucket_weight do

          0 > bucket_weight && fail  # zero OK

          # what percentage of width is taken up by this bucket?
          _width_share = width_share_via[ bucket_weight ]

          # how much normal width is that?
          my_width = @width * _width_share

          # on the leftmost subrect, avoid this cost of rational addition
          if last_additional_width
            current_x += last_additional_width
          end

          last_additional_width = my_width

          self.class.new current_x, @y, my_width, @height, thx
        end
      end

      def __build_horizontal_sequential_subdivider is_zero, weight, num_bux, thx

        # "horizontal" refers to the axis along which the imaginary blade
        # moves when it slices the rectagle, so the rect is probably tall.

        if is_zero
          zero_rational = Rational( 0 )
          height_share_via = -> _wght do
            zero_rational
          end
        else
          weight_rational = Rational( weight )
          height_share_via = -> wght do
            Rational( wght ) / weight_rational
          end
        end

        current_y = @y
        last_additional_height = nil

        -> bucket_weight do

          # what percentage of height is taken up by this bucket?
          _height_share = height_share_via[ bucket_weight ]

          # how much normal height is that?
          my_height = @height * _height_share

          # on the topmost subrect, avoid this cost of rational addition
          if last_additional_height
            current_y += last_additional_height
          end

          last_additional_height = my_height

          self.class.new @x, current_y, @width, my_height, thx
        end
      end

      # --

      def scale_and_translate_for ts  # scaler translator

        _4 = ts.scale_and_translate_rectangular self

        WorldRectangle___.new( * _4 )
      end

      # --

      def to_four  # covered-by [cm]
        [ @x, @y, @width, @height ]
      end

      attr_reader(

        # for [ba] rasterized
        :x, :y, :width, :height, :has_zero_volume
      )

    # -
    # ==

    Actions = nil  # NOTHING_  # while #open [#057] [br]
    WorldRectangle___ = ::Struct.new :x, :y, :width, :height

    # ==
  end
end
