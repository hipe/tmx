module Skylab::Basic

  module String

    module Small_Time_Actors__

      Count_occurrences_OF_string_IN_string = -> needle, haystack do

        # you could `scan`, but why? #not-covered:visually-once

        length = haystack.length
        d = 0
        count = 0
        begin
          length == d and break
          d_ = haystack.index needle, d
          d_ or break
          count += 1
          d = d_ + 1
          redo
        end while nil
        count
      end

      Count_occurrences_OF_regex_IN_string = -> rx, str do

        # you could use `scan`, but why?

        d = 0
        md = rx.match str
        while md
          d += 1
          md = rx.match str, md.offset( 0 ).last
        end
        d
      end

      class Ellipsify  # :[#032].

        Callback_::Actor.call self, :properties,
          :input_string,
          :max_width,
          :glyph

        class << self

          def call_via_arglist a
            if a.length.zero?
              self
            else
              super
            end
          end

          def curry  # meh
            -> d do
              -> s do
                self[ s, d ]
              end
            end
          end
        end  # >>

        def execute

          @glyph ||= DEFAULT_GLYPH___
          @max_width ||= String.a_reasonably_short_length_for_a_string

          if @max_width >= @input_string.length
            @input_string
          elsif @glyph.length > @max_width
            silly
          else
            work
          end
        end

        DEFAULT_GLYPH___ = '[..]'.freeze

        def work
          "#{ @input_string[ 0, @max_width - @glyph.length ] }#{ @glyph }"
        end

        def silly

          # arbitrary ASCII aesthetics for making the default glyph degrade
          # "gracefully" for small widths. :+[#it-001]

          case @max_width
          when 0 ;
          when 1 ; '.'
          when 2 ; '[]'
          when 3 ; '[.]'
          else @glyph[ 0, @max_width ]
          end
        end
      end

      class Unparenthesize_message_string

        Callback_::Actor.call self, :properties,
          :s

        def execute
          md = UNPARENTHESIZE_RX__.match @s
          md ? [ md[ :open ], md[ :body ], md[ :close ] ] : [ nil, @s, nil ]
        end

        _P = '.?!:'
        _P_ = "[#{ _P }]*"
        UNPARENTHESIZE_RX__ = /\A(?:
          (?<open> \( )  (?<body> .*[^#{ _P }] )?  (?<close> #{ _P_ }\) ) |
          (?<open> \[ )  (?<body> .*[^#{ _P }] )?  (?<close> #{ _P_ }\] ) |
          (?<open>  < )  (?<body> .*[^#{ _P }] )?  (?<close> #{ _P_ }>  ) |
                         (?<body> .+[^#{ _P }] )   (?<close> [#{ _P }]+ )
        )\z/x
      end
    end
  end
end
