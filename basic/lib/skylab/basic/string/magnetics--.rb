module Skylab::Basic

  module String

    module Magnetics__

      OccurrenceCount_via_Needle_in_Haystack = -> needle, haystack do

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

      # ==

      OccurrenceCount_via_Regex_in_String = -> rx, str do

        # you could use `scan`, but why?

        d = 0
        md = rx.match str
        while md
          d += 1
          md = rx.match str, md.offset( 0 ).last
        end
        d
      end

      # ==

      class Ellipsify_via_String  # :[#032].

        Attributes_actor_.call( self,
          :input_string,
          :max_width,
          :glyph,
        )

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
          elsif @glyph.length < @max_width
            work
          else
            silly
          end
        end

        DEFAULT_GLYPH___ = '[..]'.freeze

        def work
          "#{ @input_string[ 0, @max_width - @glyph.length ] }#{ @glyph }"
        end

        def silly

          # arbitrary ASCII aesthetics for making the default glyph degrade
          # "gracefully" for small widths. :+[#hu-001]

          case @max_width
          when 0 ;
          when 1 ; '.'
          when 2 ; '[]'
          when 3 ; '[.]'
          else @glyph[ 0, @max_width ]
          end
        end
      end

      # ==

      module UnparenthesizedPieces_via_MessageString

        p = -> s do
          md = UNPARENTHESIZE_RX___.match s
          if md
            [ md[ :open ], md[ :body ], md[ :close ] ]
          else
            [ nil, s, nil ]
          end
        end

        define_singleton_method :to_proc do p end
        define_singleton_method :_call, p
        class << self
          alias_method :[], :_call
          alias_method :call, :_call
        end

        pnct = ".?!:"
        pnct_nl = "#{ pnct }\r\n"

        body = "(?<body> .* [^#{ pnct_nl }])? (?<close> [#{ pnct }]*"
        body_ = " [\r\n]*)"

        UNPARENTHESIZE_RX___ = /\A(?:
          (?<open> \( ) #{ body } \) #{ body_ } |
          (?<open> \[ ) #{ body } \] #{ body_ } |
          (?<open> <  ) #{ body }  > #{ body_ } |
          (?<body> .* [^#{ pnct_nl }])? (?<close> [#{ pnct }\r\n]+ )
        )\z/x

        # that last phrase is: match zero or more chars whose any last
        # character is something other than a punctuation or newline-esque.
        # also, after that match *one* or more characters that *are* in
        # this same set. note this parses "foo\n" and "\n".

      end

      # ==
      # ==
    end
  end
end
# #tombstone: "unparenthesize" once had its own file
