module Skylab::Face

  class CLI::Table

    class Fill_

      module Builtins__

        class Max_Share_Meter
          def self.p_p ; PROC__ end
          PROC__ = -> column do
            new( column ).to_proc
          end

          def initialize column
            @max = column.stats.max_numeric_x.to_f
            @width = column.width
            @is_from_right = false
            absrb_any_iambic_fully column
            @glyph ||= DEFAULT_GLYPH__
            @background_glyph ||= DEFAULT_BACKGROUND_GLYPH__
            @when_no_cel_string = ( SPACE__ * @width ).freeze
            @render = if @is_from_right
              -> x, y do
                "#{ @background_glyph * y }#{ @glyph * x }"
              end
            else
              -> x, y do
                "#{ @glyph * x }#{ @background_glyph * y }"
              end
            end
            freeze
          end

          SPACE__ = ' '.freeze
          DEFAULT_GLYPH__ = '+'.freeze
          DEFAULT_BACKGROUND_GLYPH__ = SPACE__

        private
          def absrb_any_iambic_fully column
            fill = column.field.fill
            fill or raise ::ArgumentError, say_not_fill
            fill and with_x = fill.with_x
            with_x and absrb_iambic_fully with_x ; nil
          end

          def say_not_fill
            "for now, all 'max share meter' columns must be 'fill' columns."
          end

          LIB_.fields.from_methods(
            :absorber, :absrb_iambic_fully
          ) do
          def from_right
            @is_from_right = true
          end
          def glyph
            @glyph = gets_one_polymorphic_value
          end
          def background_glyph
            @background_glyph = gets_one_polymorphic_value
          end
        end

        public
          def to_proc
            -> cel do
              if cel
                when_cel cel
              else
                when_no_cel
              end
            end
          end
        private
          def when_no_cel
            @when_no_cel_string
          end
          def when_cel cel
            max_share = cel.x / @max
            num_glyphs = ( max_share * @width ).floor
            num_backgrounds = @width - num_glyphs
            @render[ num_glyphs, num_backgrounds ]
          end
        end
      end
    end
  end
end
