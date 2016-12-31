module Skylab::CodeMetrics

  class CLI__LineStream_via_NodePlus
    # while #open [#010] (brazen away) not actually under `CLI`

    class << self
      def call_by & p
        new( & p ).execute
      end
      private :new
    end  #>>

    # -
      def initialize
        yield self
        np = remove_instance_variable :@node_plus
        @__node_for_treemap = np.node
        @request = np.request
      end

      def width_and_height w, hi
        @height = hi
        @width = w ; nil
      end

      attr_writer(
        :node_plus,
      )

      def execute

        if :_stub_of_node_for_treemap_ == @__node_for_treemap
          __flush_stub
        elsif @request.do_paginate
          self._ENJOY__pagination
        else
          __execute_normally
        end
      end

      def __flush_stub
        _eek = [ :_stub_of_shapes_layers_, @width ]
        ::Skylab::CodeMetrics::Magnetics::AsciiMatrix_via_ShapesLayers.call(
          _eek, NOTHING_ )
      end

      def __execute_normally
        ok = true
        ok && __init_screen_rectangle
        ok &&= __resolve_mondrian_tree_via_node_for_treemap
        ok &&= __resolve_shapes_layers_via_mondrian_tree
        ok &&= __resolve_mondrian_ascii_choices
        ok &&= __ascii_matrix_expresser_via_choices_and_shapes_layers
        ok
      end

      def __ascii_matrix_expresser_via_choices_and_shapes_layers

        _cx = remove_instance_variable :@__mondrian_ascii_choices

        if :_no_cx_from_cm_ == _cx  # #[#007.H]
          self._WHAT
        end

        _sl = remove_instance_variable :@__shapes_layers

        st = Home_::Magnetics::AsciiMatrix_via_ShapesLayers[ _sl, _cx ]

        if st
          # ..
          st
        end
      end

      def __resolve_mondrian_ascii_choices

        if :_stub_of_shapes_layers_ == @__shapes_layers
          @__mondrian_ascii_choices = :_no_cx_from_cm_
          return ACHIEVED_
        end

        rect = @_screen_rectangle  # x, y, w, hi
        eg = NOTHING_  # these ones are just #contact-excercises

        _cx = Home_::Models::MondrianAsciiChoices.define do |o|
          o.background_fill_glyph = eg
          o.corner_pixel = eg
          o.horizontal_line_pixel = eg
          o.vertical_line_pixel = eg
          o.pixels_wide = rect.fetch( 2 )
          o.pixels_high = rect.fetch( 3 )
        end
        _store :@__mondrian_ascii_choices, _cx
      end

      def __resolve_shapes_layers_via_mondrian_tree
        _mt = remove_instance_variable :@__mondrian_tree
        _ = Home_::Magnetics::ShapesLayers_via_MondrianTree[ _mt ]
        _store :@__shapes_layers, _
      end

      def __resolve_mondrian_tree_via_node_for_treemap

        _no = remove_instance_variable :@__node_for_treemap

        if :_stub_of_node_for_treemap_ == _no  # #[#007.H]
          @__mondrian_tree = :_stub_of_mondrian_tree_
          return ACHIEVED_
        end

        mags = Home_.lib_.treemap::Magnetics  # 2x

        _qt = mags::QuantityTree_via_Node[ _no ]  # never fails

        _ratio = Squareish_ratio___[]

        _mt = mags::MondrianTree_via_QuantityTree.call _qt do |o|  # never fails (!?)
          o.target_rectangle = @_screen_rectangle
          o.portrait_landscape_threshold_rational = _ratio
        end

        _store :@__mondrian_tree, _mt
      end

      def __init_screen_rectangle

        # (last line-of-defense defaulting - probably never used)

        _width = @width || Mondrian_[]::WIDTH
        _height = @height || Mondrian_[]::HEIGHT

        @_screen_rectangle = 5, 2, _width, _height
          # #todo it appears these x, y have no effect but meh
        NIL
      end

      define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_
    # -

    # ==

    Squareish_ratio___ = Lazy_.call do

      # this is :#mon-spot-1.
      # how this ratio works is [#tm-003.2]
      # why it is this value (or near this value) is exactly [#008.A]

      # 6/11 (hi/w) is a "square" on screen.
      # we may stray from this value to achieve some amount of
      # "cheating" to some design end.

      Rational( 6 ) / Rational( 12 )
    end

    # ==
  end
end
# #born: for mondrian
