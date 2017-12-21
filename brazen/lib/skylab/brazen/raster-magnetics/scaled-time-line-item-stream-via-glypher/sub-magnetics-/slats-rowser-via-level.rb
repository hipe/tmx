module Skylab::Brazen

  class RasterMagnetics::ScaledTimeLineItemStream_via_Glypher

    class SubMagnetics_::SlatsRowser_via_Level

      # a "slats rowser" makes "slats rows"

      # -

        def initialize(
          business_column_max_width: nil,
          block_count: nil,
          row_block_boxes: nil,
          normal_column_order: nil,
          glypher: nil
        )

          if normal_column_order.do_express_business_column_first
            @left_slat_method_name = :business_slat
            @right_slat_method_name = :visualization_slat
          else
            @left_slat_method_name = :visualization_slat
            @right_slat_method_name = :business_slat
          end

          @block_count = block_count
          @row_block_boxes = row_block_boxes
          @business_column_max_width = business_column_max_width
          @glypher = glypher

          @normal_column_order = normal_column_order

          @__slats_row_prototype = SlatsRow___.prototype self
          freeze
        end

        def slats_row_via s, row_offset
          @__slats_row_prototype.new s, row_offset
        end

        attr_reader(
          :block_count,
          :business_column_max_width,
          :glypher,
          :left_slat_method_name,
          :normal_column_order,
          :right_slat_method_name,
          :row_block_boxes,
        )
      # -

      # ==

      class SlatsRow___

        # a "slats row" is one "business slat" and one "visualization slat"

        class << self
          alias_method :prototype, :new
          undef_method :new
          undef_method :dup
        end

        def initialize rsx

          @visualization_slat = VisualizationSlat___.flyweight rsx
          @business_slat = BusinessSlat___.flyweight rsx

          singleton_class.module_exec do
            alias_method :__left_slat, rsx.left_slat_method_name
            alias_method :__right_slat, rsx.right_slat_method_name
          end
        end

        def new s, row_offset

          @visualization_slat.reinit_flyweight row_offset
          @business_slat.reinit_flyweight s
          self
        end

        def to_mutable_string

          buff = ::String.new
          _ = __left_slat.to_string
          buff << _
          buff << A_B_SEPARATOR_
          s = __right_slat.to_string
          if s
            buff << s
          end
          buff
        end

        attr_reader(
          :visualization_slat,
          :business_slat,
        )
      end

      # ==

      class VisualizationSlat___

        # a "visualization slat" is the span of screen real-estate (tiles)
        # that shows the dots, etc; the visualization part of all this.

        class << self
          alias_method :flyweight, :new
          undef_method :new
        end  # >>

        def initialize rsx
          __define_reinit_flyweight_method rsx
          __define_do_to_string rsx
        end

        def __define_reinit_flyweight_method rsx

          row_block_boxes = rsx.row_block_boxes

          define_singleton_method :reinit_flyweight do |d|
            @ROW_OFFSET = d
            bx = row_block_boxes[ d ]
            if bx
              h = bx.h_
            end
            @_vizualization_tile_via_column_offset = h ; nil
          end
        end

        def to_string
          if @_vizualization_tile_via_column_offset
            __do_to_string
          end
        end

        def __define_do_to_string rsx

          gg = rsx.glypher
          s_a = gg.glyphs
          b_tree = gg.B_tree

          block_count = rsx.block_count

          define_singleton_method :__do_to_string do
            h = @_vizualization_tile_via_column_offset
            buff = ::String.new
            block_count.times do |d|
              viz_tile = h[d]
              if viz_tile
                _d_ = b_tree.category_for viz_tile.visual_weight_count
                buff << s_a.fetch( _d_ )
              else
                buff << SPACE_
              end
            end
            buff
          end
        end
      end

      # ==

      class BusinessSlat___

        # the "business slat" is the screen real estate (tiles) that shows
        # whatever line-item type thing this user is visualizing about.

        class << self
          alias_method :flyweight, :new
          undef_method :new
        end  # >>

        def initialize rsx

          # when the business column is rightmost, let the right edge of the
          # output be jagged like the business data. (because otherwise it's
          # kind of gross to pad (for example) source lines)

          if rsx.normal_column_order.do_express_business_column_first

            business_format_string = "%-#{ rsx.business_column_max_width }s"

            define_singleton_method :to_string do
              business_format_string % @business_string
            end
          else
            define_singleton_method :to_string do
              @business_string
            end
          end
        end

        def reinit_flyweight s
          @business_string = s ; nil
        end
      end

      # ==
      # ==
    end
  end
end
# #born.
