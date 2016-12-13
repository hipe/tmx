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
        _skip_any_whitespace
        @_a = []
        begin
          _ok = _parse_cel
          _ok || break
          if _no_unparsed_exists
            break
          end
          _skip_mandatory_whitespace
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
          if __parse_number
            ACHIEVED_
          else
            _maybe_accept_as_string
          end
        elsif __parse_boolean
          ACHIEVED_
        else
          _maybe_accept_as_string
        end
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

      def _maybe_accept_as_string
        if @_scn.match? QUOT___
          __quote_time
        else
          s = @_scn.scan STRING_SIMPLE___
          if s
            _accept_mixed s
          else
            # hi.
            if @_scn.skip LINE_TERMINATOR_SEQUENCE___
              # kinda gross, this ends the parsing of the line
              ACHIEVED_
            else
              self._COVER_ME__invalid_characters__
            end
          end
        end
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
      end

      def __when_unquoting_failed

        o = @_String.via_mixed.dup
        o.max_width = 40  # meh
        _early_for_now = o.against @_scn.rest

        @_listener.call :error, :expression, :parse_error, :non_terminated_quote do |y|
          y << "non terminated quote? #{ _early_for_now }"
        end

        @_a = UNABLE_
        UNABLE_
      end

      def _skip_mandatory_whitespace
        d = _skip_any_whitespace
        if ! d
          self._COVER_ME
        end
        NIL
      end

      def _skip_any_whitespace
        @_scn.skip SOME_WHITESPACE___
      end

      def _no_unparsed_exists
        @_scn.eos?
      end

      def _accept_mixed x
        @_a.push x ; ACHIEVED_
      end
    end

    # ==

    BOOLEAN_MATCHER___ = /(?:true|false|yes|no)(?=[ \t]|\z)/i
    BOOLEAN_CONVERTER___ = /\A(?: (?<true>true|yes) | (?<false>false|no) )\z/ix

    LINE_TERMINATOR_SEQUENCE___ = /(?:\n|\r\n?)\z/

    QUOT___ = /['"]/

    NUMBER_LOOKS_LIKE_BEGINNING_OF___ = /-?\d/
    NUMBER_SIMPLE_INTEGER___ = /-?\d+(?=[ \t]|\z)/
    NUMBER_SIMPLE_FLOAT___ = /-?\d+\.\d+(?=[ \t]|\z)/

    SOME_WHITESPACE___ = /[ \t]+/

    STRING_SIMPLE___ = /[^[:space:]]+/  # imagine borking on a mid-string quote

    # ==
  end
end
# #born for infer table (as mock at first). #tombstone of temporary mocks
