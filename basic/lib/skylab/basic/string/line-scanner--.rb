module Skylab::Basic

  module String

    class Line_Scanner__ < Common_::Stream.stream_class  # :[#024]

      # represent a string as a stream of "lines", each produced successively
      # through the universal minimal stream interface of a method named
      # `gets`. any trailing newline sequence is included with each produced
      # line (per the UNIX-y semantics of line "terminators" (not separators
      # [#sn-020])). (blank lines are each their own item.)
      #
      # in addition to `gets` there are two more exposed API points:
      #
      #   • the current "line number" is available thru `lineno`, with
      #     semantics similar to the synonymous platform method on an `IO`
      #     in terms of what for e.g "line 1" means.
      #
      #   • also like a platform IO, this can be rewound back to the
      #     beginning with `rewind` (because internally it uses a string
      #     scanner, but you don't know that).
      #
      # only peripherally related, a "reverse scanner" merely writes to
      # a mutable string though a yielder as proxy, writing newlines as
      # appropriate with *separator* (not terminator) semantics. as this
      # is not "correct" (per the previous above reference), this will be
      # sunsetted #todo.

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
        [ :gets, :lineno ]
      end

      def lineno
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
