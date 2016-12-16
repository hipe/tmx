module Skylab::CodeMetrics

  class Models::ShapesLayers

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

      def width_height w, h
        @mutable_model.__width_height_ w, h
        NIL
      end

      def add_layer & p
        _sl = Models::ShapeLayer.define( & p )
        @mutable_model.__add_layer_ _sl
        NIL
      end
    end

    # ==
    # -

      def initialize
        @_layers = []
      end

      def __width_height_ w, h
        @height = h
        @width = w ; nil
      end

      def __add_layer_ sl
        @_layers.push sl
        NIL
      end

      def finish
        @_layers.freeze
        freeze
      end

      # -- read

      def to_shape_layer_stream
        Stream_[ @_layers ]
      end

      attr_reader(
        :height,
        :width,
      )

    # -
    # ==
  end
end
# born
