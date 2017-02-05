module Skylab::Zerk

  module CLI::Styling

    class ChunkStream_via_String < Common_::Monadic

      # synopsis: represent ANY string as a stream that has a particular,
      # non-uniform stream-pattern (odd signature) that represents the
      # string's (any) underlying ASCII escape sequences.

      # known issues: covering *all* possible ASCII escape codes is
      # neither an interesting problem nor a desired behavior so it is
      # not something we yet offer. (but adding this "should be" trivial.)

      # deep discussion:
      #
      # the following assume a cursory understanding of ASCII escape
      # sequences; something easily acquired.
      #
      # we present here an assertion (that we do not prove but hold to
      # "feel" self-evident after the following discussion) that
      # *all strings* can be partitioned in the following way:
      #
      #   - the empty string is the empty stream
      #
      #   - all other strings (i.e all nonzero-length strings) partition
      #     into a stream such that:
      #
      #     - the first item is always a string. this string represents
      #       any leading non-styled segment of the input string. this
      #       item is the zero-length string IFF the first styled segment
      #       of the input string starts immediately at the input string's
      #       head. we enforce that such a string is always the first item
      #       produced by all such streams for all nonzero-length input
      #       strings (whew) SO THAT the "stream pattern" is consistent
      #       for all such strings, so that (in turn) clients interested
      #       only in surveying the styles utilized by the input string
      #       may do so with the same logic regardless of whether or not
      #       the input string starts immediately with a styled span, or
      #       even has any styling at all. WHEW!
      #
      #     - every remaining zero or more items of the stream is a
      #       "styled segment":
      #
      #       each such item is a tuple of two elements:
      #
      #       each such item has the one or more styles (as symbols)
      #       associated with it (in the order they were expressed in the
      #       escape expression) and the possibly zero-length string that
      #       is to be styled by this styling.
      #
      #       the "no style" signified by ASCII escape sequence using `0`
      #       is treated uniformly as a style here. (discussion below.)
      #
      #       we allow for zero-length strings in this structure because
      #       there's nothing stopping the expression agent from
      #       expressing escape sequences whose corresponding (i.e
      #       following) content string is zero-length.
      #
      # discussion: it may be tempting to think of an ASCII escape
      # sequence as similar to an "inline element" of HTML tag (like a
      # `<span>` element); but in fact these two "markup systems" are
      # *not* isomorphic (even at a fundamental, structural level), and so
      # trying to conceive of the one like the other is a "leaky
      # abstraction". rather, ASCII escape sequences can just pop up
      # spuriously anywhere in a string, and the codes they use can be
      # partially or fully redundant with codes already in effect, and
      # they certainly don't have to have anything equivalent to a
      # "close tag".
      #
      # (this dynamic resembles (to the author) the way quotes are handled
      # by some UNIX shells, as explicated excellently by [#sl-160]
      # "the Grymoire"'s AWK tutorial near "This is a very important
      # concept, and throws experienced programmers a curve ball".)
      #
      # if you try to model code `0` as a close tag you could try, but
      # here's what you'll run into:
      #
      #   - are you going to maintain a stack of each preceding escape
      #     sequence that does not contain code `0`, and then one-by-one
      #     from the topmost to the bottommost stack frame, output a
      #     "close tag"?
      #
      #   - what are you going to do for escape sequences that contain
      #     code `0` along with other codes? (and maybe code `0` isn't
      #     the last number in the escape sequence!)
      #
      # it's all a headache we avoid by expressing escape code zero
      # without any special treatement.
      #
      #
      #
      # further discussion: if you *were* to try to express an ASCII-
      # escaped string as HTML, it's certainly possible but it may not
      # be as easy as you think because of the aforementioned dis-
      # isomorphicism. in effect the performer undertaking this becomes
      # its own "rendering agent" that needs a priori knowlege of not just
      # what each escape sequence code (integer) "means" but also meta-
      # information about these meanings: i.e `red` and `green` are
      # mutually exclusive (so the last one wins), but `red` and `strong`
      # are not. if a string segment is `red;strong` but then `green` is
      # introduced, is the green still strong? what other ASCII escape
      # codes are like `strong` in this regard? what codes (if any) can
      # effectively end a `strong` run? this may be up to the rendering
      # agent, this may be part of some specification (after all, what
      # does ASCII stand for?) but regardless; we can narrow our scope
      # to a point where turning these questions into answers pulls us
      # squarely outside of it.
      #
      # having said this, it seems possible that our "all strings" would
      # be expressible in HTML as
      #
      #     nonstyled-string [ span [ span [..]]
      #
      # (these spans are not nested) where each zero or more span has a
      # perhaps inline (eew) style that expresses only those ASCII
      # ESCAPE codes (logical; so `red`, `green`, `strong`, etc) that
      # are significant after making calculations that take into account
      # the aforementioned a priori knowledge. you could also express
      # those spans that have effectively no style again as plain strings.
      #
      # since this is not something we need it's not something we
      # undertake, but we hope to have demonstrated that:
      #
      #   - such an expression of ASCII escape sequences as HTML
      #     could be facilitated (in theory) by the subject BUT
      #
      #   - such an effort is perhaps not as trivial as you might
      #     have at first assumed.

      # -

        def initialize s
          @_scn = Home_.lib_.string_scanner.new s
          NIL
        end

        def execute
          @_gets = :__gets_initially
          Common_.stream do
            send @_gets
          end
        end

        def __gets_initially
          if @_scn.eos?
            _close
          else
            s = _scan_some_plain_string
            if @_scn.eos?
              _close
            else
              @_gets = :__gets_normally
            end
            s
          end
        end

        def __gets_normally

          str = @_scn.scan ESCAPE_SEQUENCE_FOR_SCAN_RX___
          str || self._REGEX_SANITY

          md = ESCAPE_SEQUENCE_FOR_MATCH_RX___.match str
          md || self._REGEX_SANITY
          _sym_a = md[ :digits ].split( SEMICOLON_ ).map do |s|
            REVERSE_HASH___.fetch s.to_i
          end

          if @_scn.eos?
            _close
            s = EMPTY_S_
          else
            s = _scan_some_plain_string
            @_scn.eos? && _close
          end

          Chunk___[ _sym_a, s ]
        end

        def _scan_some_plain_string
          s = @_scn.scan PLAIN_RX___
          s || self._REGEX_SANITY  # the above is supposed to match all strings
          s
        end

        def _close
          remove_instance_variable :@_scn
          @_gets = :__nothing
          freeze ; NOTHING_
        end

        def __nothing
          NOTHING_
        end
      # -

      # ==

      REVERSE_HASH___ = Reverse_hash_[]

      _rxs = "\e\\[ \\d+ (?: ; \\d + )* m"

      PLAIN_RX___ = /\G
        (?: (?! #{ _rxs } ) . )*
      /mx  # should match all strins

      ESCAPE_SEQUENCE_FOR_SCAN_RX___ = /\G
        \e \[ (?: \d+ (?: ; \d+ )* ) m
      /x

      ESCAPE_SEQUENCE_FOR_MATCH_RX___ = /\A
        \e \[ (?<digits> \d+ (?: ; \d+ )* ) m
      \z/x

      # (the redundancy in the above two regexen is not necessary but
      # it makes implementation easier: the former is for "scanning"
      # and the latter is for "matching". sadly or not, StringScanner
      # lets you do the former but not the latter: StringScanner lets
      # you use Regexp to scan, but you can't access the would-be
      # captured subexpressions; i.e StringScanner never gives you a
      # MatchData, only strings or integers.
      #
      # to reduce the redundancy we could accomplish the "matching" by
      # using the string scanner and breaking it up into smaller steps,
      # but A) this would increase the codesize by probably 5x or 10x,
      # and B) we would have the added complexity of having to backtrack
      # in the case of partial but incomplete matches of expressions.
      # in the end it's too much complexity for for too little gain.)

      # ==

      Chunk___ = ::Struct.new :styles, :string

      # ==

      SEMICOLON_ = ';'

      # ==
    end
  end
end
# #history: moved from [br] to [ze]
