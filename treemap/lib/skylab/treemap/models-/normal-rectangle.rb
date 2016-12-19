module Skylab::Treemap

  class Models_::NormalRectangle

    # all values are rationals for now..

    # -
      def initialize x, y, w, hi, thx

        w.zero? && self._NEVER

        @x = Rational( x )
        @y = Rational( y )
        @width = Rational( w )
        @height = Rational( hi )
        @_threshold = thx
      end

      def _build_sequential_subdivider__ num_buckets, denom

        _is_portrait = __flush_is_portrait_not_landscape
        if _is_portrait
          __build_vertical_sequential_subdivider num_buckets, denom
        else
          __build_horizontal_sequential_subdivider num_buckets, denom
        end
      end

      def __build_horizontal_sequential_subdivider num_buckets, denom

        denom_rational = Rational( denom )

        current_x = @x
        last_additional_width = nil

        -> bucket_total do

          # what percentage of width is taken up by this bucket?
          _width_share = Rational( bucket_total ) / denom_rational

          # how much normal width is that?
          my_width = @width * _width_share

          # on the leftmost subrect, avoid this cost of rational addition
          if last_additional_width
            current_x += last_additional_width
          end

          last_additional_width = my_width

          self.class.new current_x, @y, my_width, @height, @_threshold
        end
      end

      def __build_vertical_sequential_subdivider num_buckets, denom  # COPY-mod-PASTA :/

        denom_rational = Rational( denom )

        current_y = @y
        last_additional_height = nil

        -> bucket_total do

          # what percentage of height is taken up by this bucket?
          _height_share = Rational( bucket_total ) / denom_rational

          # how much normal height is that?
          my_height = @height * _height_share

          # on the topmost subrect, avoid this cost of rational addition
          if last_additional_height
            current_y += last_additional_height
          end

          last_additional_height = my_height

          self.class.new @x, current_y, @width, my_height, @_threshold
        end
      end

      def __flush_is_portrait_not_landscape
        _actual = @height / @width
        @_threshold <= _actual
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
        :x, :y, :width, :height,  # for [ba] rasterized #here
      )

    # -
    # ==

    WorldRectangle___ = ::Struct.new :x, :y, :width, :height

    # ==
  end
end
