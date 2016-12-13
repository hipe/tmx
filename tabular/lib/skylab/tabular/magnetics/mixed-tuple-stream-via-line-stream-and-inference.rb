module Skylab::Tabular

  class Magnetics::MixedTupleStream_via_LineStream_and_Inference <
      Common_::Actor::Dyadic

    # (probably largely redundant with OGDL parser #wish [#007.B])

    # -

      def initialize line_st, inf
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
        @_prototype = MixedTuple_via_Line___.new _inference
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

      def initialize _INFERENCE
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
          _parse_cel
          if _no_unparsed_exists
            break
          end
          _skip_mandatory_whitespace
          if _no_unparsed_exists
            break
          end
          redo
        end while above
        remove_instance_variable( :@_a ).freeze  # hey why not
      end

      def _parse_cel
        if __looks_like_it_might_be_a_number
          if ! __parse_number
            _maybe_accept_as_string
          end
        elsif ! __parse_boolean
          _maybe_accept_as_string
        end
        NIL
      end

      def __looks_like_it_might_be_a_number
        @_scn.match? NUMBER_LOOKS_LIKE_BEGINNING_OF___
      end

      def __parse_number
        s = @_scn.scan NUMBER_SIMPLE_FLOAT___
        if s
          @_a.push s.to_f ; ACHIEVED_
        else
          s = @_scn.scan NUMBER_SIMPLE_INTEGER___
          if s
            @_a.push s.to_i ; ACHIEVED_
          end
        end
      end

      def __parse_boolean
        s = @_scn.scan BOOLEAN_MATCHER___
        if s
          _md = BOOLEAN_CONVERTER___.match( s )
          @_a.push _md[ :true ] ? true : false
          ACHIEVED_
        end
      end

      def _maybe_accept_as_string
        if @_scn.match? QUOT___
          self.FUNZONE
        else
          s = @_scn.scan STRING_SIMPLE___
          if s
            @_a.push s
            ACHIEVED_
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
