module Skylab::Basic

  module Pathname

    class Patterns

      class << self
        def [] s_a
          new( s_a.map do | s |
            Pattern___.new s
          end )
        end
      end  # >>

      def initialize o_a

        @pattern_a = o_a
      end

      def match s

        @pattern_a.detect do | pat |
          pat.match s
        end
      end

      class Pattern___

        # a prototype & basin for producing a regex from a glob string

        def initialize s

          scn = Home_.lib_.string_scanner s

          rx_s_a = [ '\\A' ]

          while ! scn.eos?

            s = scn.scan NOT_STAR___
            if s
              rx_s_a.push ::Regexp.escape s
            end

            d = scn.skip STAR___
            if d
              rx_s_a.push STAR_SUBSTITUTION___
            end
          end

          rx_s_a.push '\\z'

          @rx = ::Regexp.new rx_s_a.join EMPTY_S_

        end

        NOT_STAR___ = /[^*]+/
        STAR___ = /\*/
        STAR_SUBSTITUTION___ = '.*'

        def match s
          @rx =~ s
        end
      end
    end
  end
end
