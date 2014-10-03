module Skylab::Snag

  class CLI

    class Expression_Agent_

      module String_Math

        class Ellipsify

          Callback_::Actor[ self, :properties,
            :input_string, :max_width, :glyph ]

          class << self

            def via_arglist x_a
              if x_a.length.zero?
                self
              else
                super
              end
            end
          end

          def execute
            @max_width ||= A_REASONABLY_SHORT_LENGTH_FOR_A_STRING_
            @glyph ||= DEFAULT_GLYPH__
            d = @input_string.length
            if d > @max_width
              if @glyph.length > @max_width
                have_fun
              else
                work
              end
            else
              @input_string
            end
          end
          DEFAULT_GLYPH__ = '[..]'.freeze

          def work
            _d = @max_width - @glyph.length
            "#{ @input_string[ 0, _d ] }#{ @glyph }"
          end
        end
      end
    end
  end
end
