module Skylab::Basic

  module String

    module Small_Time_Actors__

      class Ellipsify

        Callback_::Actor.call self, :properties,
          :input_string,
          :max_width,
          :glyph

        class << self

          def via_arglist a
            if a.length.zero?
              self
            else
              super
            end
          end
        end

        def execute
          @max_width ||= String.a_reasonably_short_length_for_a_string
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
