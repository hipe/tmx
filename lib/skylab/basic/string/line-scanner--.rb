module Skylab::Basic

  module String

    class Line_Scanner__ < Callback_::Stream.stream_class

      # read [#024] (in [#022]) the string scanner narrative

      class << self

        def reverse s
          if block_given?
            yield Reverse__[ s ]
          else
            Reverse__[ s ]
          end
        end

        def via_arglist a

          upstream = Implementation___.new( * a )

          new upstream do
            upstream.__gets
          end
        end
      end  # >>

      def members
        [ :gets, :line_number ]
      end

      def lineno
        @upstream.__lineno
      end

      def line_number
        @upstream.__lineno
      end

      def rewind
        @upstream.__rewind
      end

      def close
        NIL_  # this is stateless unlike a real resource handle
      end

      class Implementation___

        # to be in the stream inheirance hierarchy we must contain all of our
        # state in one object that can be passed around to derivative streams

        def initialize s

          lineno = 0

          @_lineno = -> do
            lineno
          end

          scn = Home_.lib_.string_scanner s

          @_gets = -> do
            s = scn.scan LINE_RX___
            if s
              lineno += 1
            end
            s
          end

          @_rewind = -> do
            lineno = 0
            scn.pos = 0
            0  # look like file IO
          end
        end

        LINE_RX___ = String.regex_for_line_scanning

        def __gets
          @_gets[]
        end

        def __lineno
          @_lineno[]
        end

        def __rewind
          @_rewind[]
        end
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
