module Skylab::CodeMetrics

  class Models_::Tally

    class Magnetics_::Match_Stream_via_Vendor_Match_Stream

      # map-expand each line ("vendor match") to produce each match
      # from each line (where multiple matches may be on a line).

      attr_writer(
        :pattern_strings,
        :vendor_match_stream,
      )

      def execute
        if @pattern_strings.length.nonzero?
          ___execute
        end
      end

      def ___execute

        scn = Home_.lib_.string_scanner.new EMPTY_S_

        thing_rx = __build_platform_regexp
        not_thing_rx = ___build_not_thing_regexp_via thing_rx

        @vendor_match_stream.expand_by do | vm |

          string = vm.line_content

          scn.string = string

          Common_.stream do

            if ! scn.eos?

              scn.skip not_thing_rx
              d = scn.pos
              d_ = scn.skip thing_rx
              if d_
                r = d ... ( d + d_ )
                _s = string[ r ]
                Match___.new r, _s, vm
              end
            end
          end
        end
      end

      class Match___

        def initialize r, s, vm
          @range = r
          @pattern_string = s
          @vendor_match = vm
        end

        def lineno
          @vendor_match.lineno
        end

        def path
          @vendor_match.path
        end

        attr_reader(
          :range,
          :pattern_string,
          :vendor_match,
        )
      end

      def ___build_not_thing_regexp_via rx

        ::Regexp.new "(?:(?!#{ rx.source }).)+"
      end

      def __build_platform_regexp  # assume nonzero pattern strings

        pieces = [ '\b(?:' ]

        st = Stream_[ @pattern_strings ].map_by do |s|
          ::Regexp.escape s  # ..
        end

        pieces.push st.gets

        begin
          s = st.gets
          s or break
          pieces.push PIPE___
          pieces.push s
          redo
        end while nil

        pieces.push ')\b'

        ::Regexp.new pieces.join EMPTY_S_
      end

      PIPE___ = '|'
    end
  end
end
