module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Manifest_

      class Parse_Error

        def initialize a  # mutates 'a' down to empty
          @normalized_class_basename = a.shift
          @message = a.shift
          begin
            send :"#{ a.shift }=", a.shift
          end while a.length.nonzero?
          freeze
        end
        attr_accessor :line, :path
        attr_reader :column, :line_no, :message, :normalized_class_basename
        def column= s
          @column = norm_d s
        end
        def line_no= s
          @line_no = norm_d s
        end
      private
        def norm_d s
          DIGIT_RX__ =~ s or fail "not a digit: #{ s }"
          s.to_i
        end
        DIGIT_RX__ = /\A\d+\z/
      public
        def render_as_lines y=nil, &p
          Render_As_Lines.new( self, y, p ).render_as_lines ; nil
        end

        def render_ascii_graphic_location_lines y=nil, &p
          Render_As_Lines.new( self, y, p ).render_ascii_graphic_location_lines
        end

        class Render_As_Lines

          def self.[] pe, y
            new( pe, y ).render_to_lines
          end

          def initialize pe, y, p=nil
            if p
              y and raise ::ArgumentError, "can't have block and yielder"
              y = ::Enumerator::Yielder.new( & p )
            end
            @parse_error = pe ; @y = y
          end

          def render_as_lines
            render_ascii_graphic_location_lines
            @y << @parse_error.message ; nil
          end

          def render_ascii_graphic_location_lines
            pe = @parse_error
            prefix = "#{ pe.line_no }:"
            @y << "#{ prefix }#{ pe.line }"
            d = pe.column
            @y << "#{ ' ' * prefix.length }#{ '-' * ( d - 1 ) }^" ; nil
          end
        end
      end
    end
  end
end
