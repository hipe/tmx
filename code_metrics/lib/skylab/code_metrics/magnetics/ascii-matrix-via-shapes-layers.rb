module Skylab::CodeMetrics

  class Magnetics::AsciiMatrix_via_ShapesLayers < Common_::Actor::Dyadic

    # -

      def initialize sl, cx
        @ascii_choices = cx
        @shapes_layers = sl
      end

      def execute
        if :_shapes_layers_stub_ == @shapes_layers
          __do_stub
        else
          __do_real_execute
        end
      end

    def __do_stub

      _big_string = <<-HERE.unindent
        +------+
        | flim |
        | flam |
        +------+
      HERE

      _st = Home_.lib_.basic::String.line_stream _big_string

      _st   # #todo
    end

      def __do_real_execute
        __init_pixel_matrix
        __init_point_scalers
        __init_glyphs
        __write_pixels
        __flush_to_stream
      end

      def __flush_to_stream
        _ = remove_instance_variable :@pixel_matrix
        _st = Stream_.call _ do |row|
          row.join EMPTY_S_
        end
        _st
      end

      def __write_pixels
        st = @shapes_layers.to_shape_layer_stream
        while layer=st.gets
          st_ = layer.to_shape_stream
          while shape=st_.gets
            send SHAPES___.fetch( shape.category_symbol ), shape
          end
        end
        NIL
      end

      # this comment says something something visitor pattern

      SHAPES___ = {
        label: :__render_label,
        rectangle: :__render_rectangle
      }

      def __render_label world_shape
        DrawLabel___.new( world_shape, self ).execute
        NIL
      end

      def __render_rectangle world_shape
        DrawRectangle___.new( world_shape, self ).execute
        NIL
      end

      def __init_glyphs

        cx = remove_instance_variable :@ascii_choices

        @background_fill_glyph = cx.background_fill_glyph || EMPTY_PIXEL__
        @corner_pixel = cx.corner_pixel || GENERIC_CORNER_PIXEL___
        @horizontal_line_pixel = cx.horizontal_line_pixel || HORIZONTAL_LINE_PIXEL___
        @vertical_line_pixel = cx.vertical_line_pixel || VERTICAL_LINE_PIXEL___
        NIL
      end

      def __init_pixel_matrix
        o = @ascii_choices
        matrix = []
        row_prototype = o.pixels_wide.times.map { EMPTY_PIXEL__ }
        o.pixels_high.times do
          matrix.push row_prototype.dup
        end
        @pixel_matrix = matrix ; nil
      end

      def __init_point_scalers

        ascii = @ascii_choices
        world = @shapes_layers

        @_scale_x = ascii.pixels_wide.to_f / world.width
        @_scale_y = ascii.pixels_high.to_f / world.height

        NIL
      end
    # -

    # ==

    DrawRectangular__ = ::Class.new

    class DrawLabel___ < DrawRectangular__

      def initialize shape, surface
        @label_string = shape.label_string
        super
      end

      def execute

        x = @screen_x ; s = @label_string ; w = @screen_width

        number_of_blank_spaces = w - s.length

        case number_of_blank_spaces <=> 0

        when -1  # too many characters to fit..

          _write_string x, s[ 0, w ] # meh

        when 0   # exactly enough characters to fit

          _write_string x, s

        when 1   # more space than there is characters..

          _indent_by_this_much = number_of_blank_spaces / 2
            # when number is odd it nudges to the left which is better

          _use_x = x + _indent_by_this_much

          _write_string _use_x, s
        end
        NIL
      end

      def _write_string x, str

        row = @surface.pixel_matrix.fetch @screen_y
        col = x - 1
        str.length.times do |d|
          col += 1
          row[ col ] = str[ d ]
        end
        NIL
      end
    end

    class DrawRectangle___ < DrawRectangular__

      def initialize shape, surface
        # hi.
        super
      end

      def execute

        pen_drag @screen_x, @screen_y do |o|

          # (start from top left corner, go around clockwise)

          o.generic_corner
          o.horizontal_inner_line @screen_width
          o.generic_corner
          o.vertical_inner_line @screen_height
          o.generic_corner
          o.horizontal_inner_line( - @screen_width )
          o.generic_corner
          o.vertical_inner_line( - @screen_height )
        end

        @surface.__fill_rect_ self
        NIL
      end
    end

    class DrawRectangular__

      # the only lesson learned so far that we didn't forsee in pseudocode
      # is that you should scale once and scale early. if you scale late,x
      # rounding issues can put holes in your shape outlines between the
      # arcs and the corners. (and scaling the same x's or y'x more than
      # once in the same "draw" feels wrong.) :#here-1

      # each particular kind of shape must make its own shape-category-
      # specific and shape-specific choices for how to pixelate, but it
      # should do so in the context of screen coordinates and not world
      # coordinates so it can know the discrete pixels it's making trade-
      # off choices around..

      def initialize shape, surface

        @screen_x, @screen_y, @screen_width, @screen_height =
          surface.__scale_rectangular_ shape

        @surface = surface
      end

      def pen_drag screen_x, screen_y

        pd = PenDrag___.new screen_x, screen_y, @surface
        yield pd
        pd.finish
        NIL
      end

      attr_reader(
        :screen_x,
        :screen_y,
        :screen_width,
        :screen_height,
      )
    end

    # ==

    class PenDrag___

      # a convenience abstraction modeling the continuous action of putting
      # an imaginary "pen" down on the screen and moving it around, like an
      # etch-a-sketch. the pen "lifting" coincides with the session finishing.

      # it's mainly an interface on top of the lower level drawing
      # primitives exposed by the "surface", one that keeps a current
      # position in state so you don't have to repeat it in code.

      def initialize x, y, surface
        @x = x ; @y = y  # screen_x, screen_y
        @surface = surface
      end

      def horizontal_inner_line w

        # the "inner line" of a rectangle edge is those continuous pixels
        # between two adjacent corner pixels; and it is shrunk down to
        # zero length IFF the rectangle along that axis is the smallest
        # it can be (2 pixels).

        # if you drew a line of width N you move the coordinate
        # by N-1 for whatever reason.

        case w <=> 0
        when 1  # width is positive
          if 2 < w
            @surface._horizontal_inner_line_ @x, @y, w
          end
          @x += ( w - 1 )
        when -1  # width is negative
          x_ = @x + w + 1
          if -2 > w
            @surface._horizontal_inner_line_ x_, @y, -w
          end
          @x = x_
        end
        # (if width is zero, ignore)

        NIL
      end

      def vertical_inner_line hi  # counterpart

        case hi <=> 0
        when 1  # height is positive
          if 2 < hi
            @surface._vertical_inner_line_ @x, @y, hi
          end
          @y += ( hi - 1 )
        when -1  # height is negative
          y_ = @y + hi + 1
          if -2 > hi
            @surface._vertical_inner_line_ @x, y_, -hi
          end
          @y = y_
        end

        NIL
      end

      def generic_corner
        @surface._generic_corner__ @x, @y
        NIL
      end

      def finish
        remove_instance_variable :@surface
        NIL
      end
    end

    # ==
    # - (re-open subject, but for support of above)

      def __fill_rect_ o  # o = screen rect

        w = o.screen_width ; hi = o.screen_height

        # if a rectangle is the smallest it can be (2 pixels) along either
        # (or both) axes, it has width but no inside pixels, so skip fill.

        if 2 < w && 2 < hi

          p = _horizontal_liner(
            o.screen_x + 1,
            w - 2,
            @background_fill_glyph,
          )

          y = o.screen_y
          ( y + 1 ... y + hi - 1 ).each do |y_|
            p[ y_ ]
          end
        end

        NIL
      end

      def _horizontal_inner_line_ screen_x, screen_y, screen_w

        2 < screen_w || sanity

        _horizontal_liner(
          screen_x + 1,
          screen_w - 2,
          @horizontal_line_pixel,
        )[ screen_y ]
        NIL
      end

      def _vertical_inner_line_ screen_x, screen_y, screen_hi

        2 < screen_hi || sanity
        _vertical_line(
          screen_x,
          screen_y + 1,
          screen_hi - 2,
          @vertical_line_pixel,
        )
        NIL
      end

      def _generic_corner__ screen_x, screen_y

        @pixel_matrix.fetch( screen_y )[ screen_x ] = @corner_pixel
        NIL
      end

      def _horizontal_liner screen_x, width, pixel

        next_screen_x = screen_x + width

        -> screen_y do
          row = @pixel_matrix.fetch screen_y
          ( screen_x ... next_screen_x ).each do |d|
            row[ d ] = pixel
          end
          NIL
        end
      end

      def _vertical_line x, y, hi, pix

        a = @pixel_matrix

        ( y ... y + hi ).each do |d|
          a.fetch( d )[ x ] = pix
        end
        NIL
      end

      def __scale_rectangular_ rect

        # (we lose precision by collapsing to integers what we could
        #  keep as floats until later, but we're following #here-1
        #  and KISS for now.)

        [
          ( @_scale_x * rect.x ).to_i,
          ( @_scale_y * rect.y ).to_i,
          ( @_scale_x * rect.width ).to_i,
          ( @_scale_y * rect.height ).to_i,
        ]
      end

      attr_reader(
        :pixel_matrix,
      )

    # -
    # ==

    EMPTY_PIXEL__ = ' '
    GENERIC_CORNER_PIXEL___ = '+'
    HORIZONTAL_LINE_PIXEL___ = '-'
    VERTICAL_LINE_PIXEL___ = '|'

    # ==
  end
end
# #born as mock
