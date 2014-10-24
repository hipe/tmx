module Skylab::Basic

  module String

    class Line_Scanner__  # read [#024] (in [#022]) the string scanner narrative

      class << self

        def reverse s
          if block_given?
            yield Reverse__[ s ]
          else
            Reverse__[ s ]
          end
        end
      end

      def initialize s
        @count = 0
        scn = Basic_::Lib_::String_scanner[ s ]
        @gets_p = -> do
          s = scn.scan LINE_RX__
          if s
            @count += 1
            s
          else
            scn.eos? or fail "sanity - rx logic failure"
            @gets_p = EMPTY_P_ ; nil
          end
        end ; nil
      end

      def gets
        @gets_p.call
      end

      def line_number
        @count.nonzero?
      end

      LINE_RX__ = String.regex_for_line_scanning

      Reverse__ = -> mutable_string do
        is_first = true
        ::Enumerator::Yielder.new do |line|
          if is_first
            is_first = false
            mutable_string.concat line
          else
            mutable_string.concat "#{ NEWLINE_ }#{ line }"
          end ; nil
        end
      end
    end
  end
end
