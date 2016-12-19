module Skylab::CodeMetrics

  class Models::ShapeLayer

    class << self
      def define
        o = new
        yield DSL___.new o
        o.finish
      end
      private :new
    end  # >>

    # ==

    class DSL___

      def initialize o
        @mutable_model = o
      end

      def add_label x, y, w, h, s
        @mutable_model._push_shape_ Label___.new x, y, w, h, s
        NIL
      end

      def add_rect x, y, w, h
        @mutable_model._push_shape_ Rectangle__.new x, y, w, h
        NIL
      end
    end

    # ==
    # -

      def initialize
        @_shapes = []
      end

      def _push_shape_ shape
        @_shapes.push shape ; nil
      end

      def finish
        @_shapes.freeze
        freeze
      end

      # -- read

      def to_shape_stream
        Stream_[ @_shapes ]
      end
    # -
    # ==

    Rectangle__ = ::Class.new

    class Label___ < Rectangle__  # near [#007.E] (follow to its end)

      def initialize * four, s

        @label_string = if s.frozen?
          s
        else
          # for now, if you don't pass a frozen string,
          # punished by having your string frozen on you.
          s.freeze
        end

        super( * four )
      end

      attr_reader :label_string

      def category_symbol
        :label
      end
    end

    # ==

    class Rectangle__
      def initialize x, y, w, h
        @x = x ; @y = y ; @width = w ; @height = h
        freeze
      end
      attr_reader(
        :x, :y, :width, :height,
      )
      def category_symbol
        :rectangle
      end
    end

    # ==

    # ==
  end
end
# born
