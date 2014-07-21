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
            absrb_iambic_fully column.field.fill.with_x
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

        Face_::Lib_::Fields_from_methods[ :absorber, :absrb_iambic_fully, -> do
          def from_right
            @is_from_right = true
          end
          def glyph
            @glyph = iambic_property
          end
          def background_glyph
            @background_glyph = iambic_property
          end
        end ]

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
