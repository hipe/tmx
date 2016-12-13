module Skylab::Tabular

  class Magnetics::MixedTupleStream_via_LineStream_and_Inference <
      Common_::Actor::Dyadic

    # (probably largely redundant with OGDL parser #wish [#007.B])

    # -

      def initialize line_st, inf, & p
        @_listener = p

        @inference = inf
        @line_upstream = line_st
      end

      def execute
        @_gets_tuple = :__gets_very_first_tuple
        Common_.stream do
          send @_gets_tuple
        end
      end

      def __gets_very_first_tuple
        line = @line_upstream.gets
        if line
          __do_gets_very_first_tuple line
        else
          remove_instance_variable :@line_upstream
          NOTHING_
        end
      end

      def __gets_tuple_normally
        line = @line_upstream.gets
        if line
          _tuple_via_line line
        end
      end

      def __do_gets_very_first_tuple line

        _inference = remove_instance_variable :@inference
        @_prototype = MixedTuple_via_Line___.new _inference, & @_listener
        @_gets_tuple = :__gets_tuple_normally
        freeze
        _tuple_via_line line
      end

      def _tuple_via_line line
        @_prototype.new( line ).execute
      end
    # -

    # ==

    class MixedTuple_via_Line___

      def initialize _INFERENCE, & listener
        @_listener = listener
        @_scn = Home_.lib_.string_scanner.new EMPTY_S_
        freeze
      end

      private :dup

      def new line
        dup.__init line
      end

      def __init line
        @_scn.string = line ; self
      end

      def execute

        _skip_whitespace

        @_a = []
        @_done = false

        begin
          _parse_cel
          @_done && break

          if _skip_whitespace
            redo
          end

          if _skip_line_terminator
            break
          end

          if _no_unparsed_exists
            break
          end

          redo
        end while above

        a = remove_instance_variable :@_a
        if a
          a.freeze  # hey why not
        end
        a
      end

      def _parse_cel
        if __looks_like_it_might_be_a_number
          if ! __parse_number
            _attempt_to_accept_as_string
          end
        elsif ! __parse_boolean
          _attempt_to_accept_as_string
        end
        NIL
      end

      def __looks_like_it_might_be_a_number
        @_scn.match? NUMBER_LOOKS_LIKE_BEGINNING_OF___
      end

      def __parse_number
        s = @_scn.scan NUMBER_SIMPLE_FLOAT___
        if s
          _accept_mixed s.to_f
        else
          s = @_scn.scan NUMBER_SIMPLE_INTEGER___
          if s
            _accept_mixed s.to_i
          end
        end
      end

      def __parse_boolean
        s = @_scn.scan BOOLEAN_MATCHER___
        if s
          _md = BOOLEAN_CONVERTER___.match( s )
          _accept_mixed _md[ :true ] ? true : false
        end
      end

      def _attempt_to_accept_as_string
        if @_scn.match? QUOT___
          __quote_time
        else
          s = @_scn.scan STRING_SIMPLE___
          if s
            _accept_mixed s
          elsif _skip_line_terminator
            # kinda gross, this ends the parsing of the line
            _stop
          else
            self._COVER_ME__invalid_characters__
          end
        end
        NIL
      end

      def __quote_time

        @_String = Home_.lib_.basic::String

        s = @_String.quoted_string_literal_library.
          unescape_quoted_literal_at_scanner_head @_scn

        if s
          _accept_mixed s
        else
          __when_unquoting_failed
        end
        NIL
      end

      def __when_unquoting_failed

        o = @_String.via_mixed.dup
        o.max_width = 40  # meh
        _early_for_now = o.against @_scn.rest

        @_listener.call :error, :expression, :parse_error, :non_terminated_quote do |y|
          y << "non terminated quote? #{ _early_for_now }"
        end

        @_a = UNABLE_
        _stop
        NIL
      end

      def _skip_line_terminator
        @_scn.skip LINE_TERMINATOR_SEQUENCE___
      end

      def _skip_whitespace
        @_scn.skip SOME_WHITESPACE___
      end

      def _no_unparsed_exists
        @_scn.eos?
      end

      def _stop
        @_done = true ; nil
      end

      def _accept_mixed x
        @_a.push x
        ACHIEVED_  # used sometimes, not others
      end
    end

    # ==

    ce = '(?=[[:space:]]|\z)'  # common end

    BOOLEAN_MATCHER___ = /(?:true|false|yes|no)#{ ce }/i
    BOOLEAN_CONVERTER___ = /\A(?: (?<true>true|yes) | (?<false>false|no) )\z/ix

    LINE_TERMINATOR_SEQUENCE___ = /(?:\n|\r\n?)\z/

    QUOT___ = /['"]/

    NUMBER_LOOKS_LIKE_BEGINNING_OF___ = /-?\d/
    NUMBER_SIMPLE_INTEGER___ = /-?\d+#{ ce }/
    NUMBER_SIMPLE_FLOAT___ = /-?\d+\.\d+#{ ce }/

    SOME_WHITESPACE___ = /[ \t]+/

    STRING_SIMPLE___ = /[^[:space:]]+/  # imagine borking on a mid-string quote

    # ==
  end
end
# #born for infer table (as mock at first). #tombstone of temporary mocks
