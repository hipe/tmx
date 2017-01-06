module Skylab::CodeMetrics

  class Magnetics::AsciiMatrix_via_ShapesLayers < Common_::Actor::Dyadic

    # -

      def initialize sl, cx
        @ascii_choices = cx
        @shapes_layers = sl
      end

      def execute

        #== begin #[#007.H]

        a = ::Array.try_convert @shapes_layers
        if a
          is_stub = true
          stub_tuple = a
        end

        #== end

        if is_stub
          __do_stub stub_tuple
        else
          __do_real_execute
        end
      end

      def __do_stub stub_tuple

        _, width = stub_tuple

        _big_string = if width == Mondrian_[]::WIDTH
          __stubbed_big_string_normally
        else
          __stubbed_big_string_via_width width
        end

        Basic_[]::String.line_stream _big_string
      end

      def __stubbed_big_string_via_width w
        _wee = <<-HERE.unindent
          +----------+
          | pretend  |
          | i am #{ '%3d' % w } |
          | wide     |
          +----------+
        HERE
        _wee
      end

      def __stubbed_big_string_normally
        <<-HERE.unindent
        +------+
        | flim |
        | flam |
        +------+
        HERE
      end

      def __do_real_execute
        __init_pixel_matrix
        __init_normal_point_scaler
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

      def __init_normal_point_scaler

        cx = @ascii_choices
        wo = @shapes_layers

        @__normal_rectangular_pixelator =
            Basic_[]::Rasterized::NormalRectangularPixelator.
        via_screen_vector_and_world_vector(
          cx.pixels_wide,
          cx.pixels_high,
          wo.width,
          wo.height,
        )
        NIL
      end
    # -

    # ==

    DrawRectangular__ = ::Class.new

    class DrawLabel___ < DrawRectangular__

      # :[#007.E] vertical centering (& related) is a moving-target
      # micro-API. consider this an experimental version of it:
      #
      # the rectangular coordinates that accompany a label definition
      # correspond to the rectangular shape or area the label refers to.
      #
      # this is, they do *not* indicate the horizontal or vertical
      # span of space the label is meant to "fill" or "stretch" into.
      #
      # rather, the modality is on its own to decide the appropriate
      # positioning, clipping, truncation, horizontal stretching, and
      # (imaginarily) font & font size for the label as appropriate to
      # the modality and shape being labeled.

      # here in ASCII-land, that means these translational dynamics:
      #
      #   - for now we're not gonna mess with some novelty act like
      #     horizontal stretching (allà `[[ i n c e p t i o n ]]`).
      #
      #   - likewise we're not even gonna think about a `banner` or
      #     `figlet` type external service..
      #
      # tricks like these are so out of scope that they would take
      # us backwards: by adding any such complexity they miss the point
      # entirely of the ASCII target (notwithstanding a change of our
      # would-be (non-written) mission statement).
      #
      # so for now it's always monospaced, letter-per-letter spacing.
      # in the other direction:
      #
      #   - because of the definitional axiom (that the label's rect *is*
      #     the rect being described), we would sometimes overprint the edge
      #     decoration of rectangles except that we take steps to avoid it
      #     :#here-2. (this workaround, in turn, will cause frustrating
      #     behavior if ever we label something other that rects (e.g empty
      #     space or an arc between them) but for now we don't..
      #
      #   - our implementation of "ellipsifying" strings that are too long
      #     is as crude as can be, but see comment above about "missing
      #     the point".

      def initialize shape, surface
        @label_string = shape.label_string
        super
      end

      def execute
        @_drawable_width = @screen_width - TWO__
        @_drawable_height = @screen_height - TWO__

        if 0 < @_drawable_width && 0 < @_drawable_height
          __draw_something
        end
      end

      def __draw_something

        # as it works out, this function is concerned with horizontal
        # centering and the callee will deal with vertical centering.

        s = @label_string
        leftmost_x = @screen_x + 1

        number_of_blank_spaces = @_drawable_width - s.length

        case number_of_blank_spaces <=> 0

        when -1  # too many characters to fit..

          _write_string leftmost_x, s[ 0, @_drawable_width ] # see "crude" above

        when 0   # exactly enough characters to fit

          _write_string leftmost_x, s

        when 1   # more space than there is characters..

          _indent_by_this_much = number_of_blank_spaces / 2
            # when number is odd it nudges to the left which is better

          _use_x = leftmost_x + _indent_by_this_much

          _write_string _use_x, s
        end
        NIL
      end

      def _write_string x, str

        # @screen_y is the row with the edge decoration.

        # when drawable height is 1, use_y is @screen_y + 1
        # when drawable height is 2, (same)
        # when drawable height is 3, use_y is @screen_y + 2
        # when drawable height is 4, (same)
        # ..

        _add_this = ( @_drawable_height - 1 ) / 2 + 1
          # plus one for "never draw over the top edge decoration"

        _use_y = @screen_y + _add_this

        row = @surface.pixel_matrix.fetch _use_y
        str.length.times do |d|
          row[ x + d ] = str[ d ]
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
      # is that you should scale once and scale early. if you scale late,
      # rounding issues can put holes in your shape outlines between the
      # arcs and the corners. (and scaling the same x's or y'x more than
      # once in the same "draw" feels wrong.) :#here-1

      # each particular kind of shape must make its own shape-category-
      # specific and shape-specific choices for how to pixelate, but it
      # should do so in the context of screen coordinates and not world
      # coordinates so it can know the discrete pixels it's making trade-
      # off choices around..

      def initialize normal_shape, surface

        @screen_x, @screen_y, @screen_width, @screen_height =
          surface.__pixelate_normal_rectangular normal_shape

        @normal_shape = normal_shape
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
          if TWO__ < w
            @surface._horizontal_inner_line_ @x, @y, w
          end
          @x += ( w - 1 )
        when -1  # width is negative
          x_ = @x + w + 1
          if -TWO__ > w
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
          if TWO__ < hi
            @surface._vertical_inner_line_ @x, @y, hi
          end
          @y += ( hi - 1 )
        when -1  # height is negative
          y_ = @y + hi + 1
          if -TWO__ > hi
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

        if TWO__ < w && TWO__ < hi

          p = _horizontal_liner(
            o.screen_x + 1,
            w - TWO__,
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

        TWO__ < screen_w || sanity

        _horizontal_liner(
          screen_x + 1,
          screen_w - TWO__,
          @horizontal_line_pixel,
        )[ screen_y ]
        NIL
      end

      def _vertical_inner_line_ screen_x, screen_y, screen_hi

        TWO__ < screen_hi || sanity
        _vertical_line(
          screen_x,
          screen_y + 1,
          screen_hi - TWO__,
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

      def __pixelate_normal_rectangular rect

        # (this is the point at which we collapse from rational numbers
        #  to integers for the ASCII raster. we have to do it now because
        #  of #here-1 rounding issues that can put holes in shape edges.)

        @__normal_rectangular_pixelator.pixelate_world_rectangular rect
      end

      attr_reader(
        :pixel_matrix,
      )

    # -
    # ==

    # ==

    EMPTY_PIXEL__ = ' '
    GENERIC_CORNER_PIXEL___ = '+'
    HORIZONTAL_LINE_PIXEL___ = '-'
    TWO__ = 2  # when used to take into account "edge decoration"
    VERTICAL_LINE_PIXEL___ = '|'

    # ==
  end
end
# #born as mock
