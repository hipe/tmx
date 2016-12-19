module Skylab::Basic

  module Rasterized

    # about the placement of this node:
    #
    #   - both [cm] and [tr] seem to want to do something like this,
    #     and it seems appropriate for neither one to be the
    #     proprietor of it.
    #
    #   - to make a whole "rasterized" sidesystem is premature.
    #
    #   - but still this feels a little more general than belonging to [ze].
    #
    # so here it is.

    # about this micro-API:
    #
    #   - the formal arguments for a scale/translate methods are typically
    #     one: a struct-ish with assumed accessor names like
    #     (`x`, `y`, `width`, `height`). justification: in practice the
    #     client typically has ivars like these anyway.
    #
    #   - in contrast to the above, results that model shapes are typically
    #     arrays ("tuples") of these same terms in this order, and not
    #     structs. justification: we expect that the client will want to use
    #     her own ad-hoc business class to model the resulting rect, and not
    #     one of our chosing.

    class NormalRectangularPixelator

      # the core calculations to scale a [#tr-003.1] "normal rectangle" for
      # a screen are theoretically straightforward: since the units used in
      # a normal rectangle's coordinates and distances are by definition in
      # terms of the initial rectangle's width (i.e 1.0 is always the width
      # of the initial rectangle), then if we know the width of the
      # corresponding screen rectangle, theoretically all we need to do is
      # multiply all four components by this value.

      # but because we are pixelating, it's not so simple: we need to
      # arrange it so that the jaggedness caused by collapsing from
      # rationals to integers occurs in a consistent way (*any* consistent
      # way). to this end, a few tricks:

      # A) don't calculate the width and height as described above. rather,
      # add the normal width and normal height to the normal x and normal y
      # and get the ints for those. these will be the x and y of the
      # imaginary next shape over. then, the distance from x to x' is the
      # "pixelated" width, and the distance from y to y' the "pixelated"
      # height. (yes, these widths and heights will be sometimes different
      # than if you just converted the rational widths and heights using
      # the unit term. try changing it and see the difference in [cm].)

      # B) we're still thinking about (B), but it will be something like
      # detecting when a shape is at the outermost edge (far right and/or
      # far bottom), and always going `ciel` for these.
      # (B) appears to maybe not be an issue since we did (A)..

      class << self
        alias_method :via_screen_vector_and_world_vector, :new
        undef_method :new
      end  # >>

      def initialize pix_w, pix_hi, world_w, world_hi

        horiz_factor_rat = Rational( pix_w ) / Rational( world_w )

        vert_factor_rat = Rational( pix_hi ) / Rational( world_hi )

        @_pixelate_horizontal = -> rational do
          ( horiz_factor_rat * rational ).to_i
        end

        @_pixelate_vertical = -> rational do
          ( vert_factor_rat * rational ).to_i
        end
      end

      def pixelate_world_rectangular world

        # exactly (A) above.

        _next_x_over_normal = world.x + world.width
        _next_y_over_normal = world.y + world.height
        _next_x_over = @_pixelate_horizontal[ _next_x_over_normal ]
        _next_y_over = @_pixelate_vertical[ _next_y_over_normal ]

        screen_x = @_pixelate_horizontal[ world.x ]
        screen_y = @_pixelate_vertical[ world.y ]

        [ screen_x,
          screen_y,
          _next_x_over - screen_x,
          _next_y_over - screen_y,
        ]
      end
    end

    class ScalerTranslator

      class << self
        alias_method :via_normal_rectangle, :new
        undef_method :new
      end  # >>

      # convert our internal normal rationals back to world values

      def initialize world_x, world_y, world_w, world_hi

        if world_w.respond_to? :bit_length
          @_scale_horizontal = -> rational do
            ( rational * world_w ).to_i
          end
        else
          self._DO_ME_float_world
        end

        world_width_rational = Rational( world_w )

        if world_hi.respond_to? :bit_length
          @_scale_vertical = -> rational do
            ( rational * world_width_rational ).to_i
          end
        else
          self._DO_ME_float_world
        end

        @normal_rectangle_height = Rational( world_hi ) / world_width_rational

        @world_x = world_x
        @world_y = world_y
        @world_width = world_w
        @world_height = world_hi
      end

      def scale_and_translate_rectangular o

        _world_w = @_scale_horizontal[ o.width ]
        _world_hi = @_scale_vertical[ o.height ]

        _pre_trans_x = @_scale_horizontal[ o.x ]
        _pre_trans_y = @_scale_vertical[ o.y ]

        _world_x = @world_x + _pre_trans_x
        _world_y = @world_y + _pre_trans_y

        [ _world_x, _world_y, _world_w, _world_hi ]
      end

      attr_reader(  # for [cm]
        :normal_rectangle_height,  # convenince
        :world_x,
        :world_y,
        :world_width,
        :world_height,
      )
    end
  end
end
# #born: for the realization of the dream of [tr], thru [cm]
