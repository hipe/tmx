module Skylab::Basic

  module String

    class Line_Scanner__ < Callback_::Stream.stream_class

      # read [#024] (in [#022]) the string scanner narrative

      class << self

        def new * x_a, & p

          case x_a.length
          when 1
            s = x_a.first  # meh
            count = 0
            scn = Basic_.lib_.string_scanner s
            p = -> do
              s = scn.scan LINE_RX__
              if s
                count += 1
                s
              else
                p = EMPTY_P_
                nil
              end
            end
            super -> { count } do
              p[]
            end
          when 0  # when maps, reduces etc are used, you lose the line count for now
            superclass.new( & p )
          end
        end

        LINE_RX__ = String.regex_for_line_scanning

        def reverse s
          if block_given?
            yield Reverse__[ s ]
          else
            Reverse__[ s ]
          end
        end
      end  # >>

      def initialize count_p, & p

        @count_p = count_p
        super( & p )
      end

      def members
        [ :gets, :line_number ]
      end

      def line_number
        @count_p.call.nonzero?
      end

      private def new & p  # re-write parent, because we re-wrote `cls.new`
        self.class.new( & p )
      end

      Reverse__ = -> mutable_string do  # see #the-reverse-scanner
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
