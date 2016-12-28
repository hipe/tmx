module Skylab::CodeMetrics

  class Magnetics::ShapesLayers_via_MondrianTree < Common_::Actor::Monadic

    # NOTE - mondrian tree has a scaler-translator we're not using

    # note - shapes-layers has a layers facility we're not using

    # remember this is not ascii yet so we're not going to snap the
    # vertexes into slots yet. for now we'll just carry-over the
    # normal rational values.

    # at the moment our approach is very simple - don't draw rects
    # that have child rects; draw only the terminal items. this choice
    # will have consequences in that
    #   A) will probably need to change for [#007.B] whitespace for whitespace
    #   B) if [#007.C] convert shapes to latticework, something.

    def initialize mt
      @mondrian_tree = mt
    end

    def execute

      if :_stub_of_mondrian_tree_ == @mondrian_tree  # #[#007.H]
        return :_stub_of_shapes_layers_
      end

      Home_::Models::ShapesLayers.define do |sls|

        @_same_shapes_layers = sls

        __send_width_and_height

        _an = @mondrian_tree.mesh_node

        sls.add_layer do |sl|
          @_same_shape_layer = sl
          freeze
          _recurse _an
        end
        NIL
      end
    end

    def _recurse mesh_branch

      mesh_branch.normal_rectangle  # IGNORED - #contact-exercise

      mesh_branch.mesh_nodes.each do |mn|

        if mn.is_branch
          _recurse mn
        else
          __when_terminal_item mn
        end
      end
      NIL
    end

    def __when_terminal_item mesh_node

      four = mesh_node.normal_rectangle.to_four

      @_same_shape_layer.add_rect( * four )
        # would change at [#007.C] - latticework not squares

      _label_string = mesh_node.tuple.label_string

      @_same_shape_layer.add_label( * four, _label_string )  # near #[#007.E]

      NIL
    end

    def __send_width_and_height

      # the remote lib gives us rectangles in [#tr-003.1] "normal
      # rectangle units" and it also gives us a scaler-translator to
      # convert the normal rectangles into whatever coordinate system was
      # associated with the mondrian tree at the beginning.
      #
      # we don't really care about the units associated with the mondrian
      # tree at the beginning because we will be targeting our own
      # arbitrary (for example) ASCII raster; except that we need to know
      # the aspect ratio of the original initial rectangle so we know
      # how to interpret the normal rectangle heights. (normal rectangle
      # widths are always relative to (and less than or equal to) 1.0,
      # as explained in the referenced doc node.)
      #
      # NOTE this is probably confused - #open :[#007.D]: we want direct,
      # clean hops from "mondrian tree" world to "shapes layers" world to
      # rasterized ASCII world. as such during this heavily mocked phase
      # we told the mondrian tree to target the coordinate system of some
      # arbitrary bounding rect width/height. the thing is, the mondrian
      # system should to know the aspect ratio (if not scale) of the final
      # targeted rect (read: ASCII) so it can make appropriate decisions
      # about which orientation to make the splits in. so we must keep that
      # in mind as we transition off the mocks..

      ts = @mondrian_tree.scaler_translator

      ts.world_x || fail  # #contact-exercise (both)
      ts.world_y || fail

      # tell ourselves we'll be using [#tr-003.1] "normal rectangle units":

      @_same_shapes_layers.width_height 1.0, ts.normal_rectangle_height
      NIL
    end
  end
end
