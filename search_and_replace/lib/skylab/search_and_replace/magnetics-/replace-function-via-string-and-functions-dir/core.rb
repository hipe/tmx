module Skylab::SearchAndReplace

  class Magnetics_::Replace_Function_via_String_and_Functions_Dir < Callback_::Actor::Dyadic

    def initialize string, functions_dir, & oes_p

      @_a = []
      @functions_dir = functions_dir
      @_scn = Home_.lib_.string_scanner.new string

      @_oes_p = oes_p
    end

    def execute
      _ok = ___parse
      _ok && Self_::Replace_Function__.new( @_a )
    end

    def ___parse

      ok = true
      scn = @_scn

      until scn.eos?

        d = scn.charpos  # (using `.pos` instead might be fine)
        normal = scn.scan NORMAL_RX__
        open = scn.skip OPEN_RX__
        d == scn.charpos and self._SANITY

        if normal
          ok = ___process_normal_mutable_string normal
          ok or break
        end

        if open
          ok = __parse_replacement_expression
          ok or break
        end
      end
      ok
    end

      NORMAL_RX__ = /(?:(?!\{\{).)+/m

      OPEN_RX__ = /{{/

    def ___process_normal_mutable_string string

      ok = true

      string.gsub! ETC_RX__ do

        s = $~[ 1 ]
        if s
          p = UNESCAPE_OK_MAP__[ s.getbyte 0 ]
        end

        if p
          p[ s ]
        else
          ok = ___when_invalid_escape_sequence s
          break
        end
      end

      if ok
        _add_normal_string string
      else
        ok
      end
    end

      ETC_RX__ = /\\(.)?/

      UNESCAPE_OK_MAP__ = {
        '\\'.getbyte( 0 ) => -> _ { '\\' },
        'n'.getbyte( 0 ) => -> _ { "\n" },
        't'.getbyte( 0 ) => -> _ { "\t" } }

    def ___when_invalid_escape_sequence s ; self._COVER_ME

      @_oes_p.call :error, :expression, :invalid_escape_sequence do |y|
        y << s
      end

      UNABLE_
    end

    def __parse_replacement_expression

      @_scn.skip WHITE_RX_

      if @_scn.skip DOLLA_RX__
        __parse_magic

      elsif @_scn.skip LITERAL_OPEN_EXPRESSION_RX__
        ___parse_literal_open_expression

      else
        _expected :capture_reference, OPEN_BRACE_EXPRESSON__
      end
    end

      DOLLA_RX__ = /\$/

      LITERAL_OPEN_EXPRESSION_RX__ = /"\{\{"/

    def ___parse_literal_open_expression

      @_scn.skip WHITE_RX_

      if @_scn.skip CLOSE_RX_
        _add_normal_string OPEN_BRACE_EXPRESSON__
      else
        _expected CLOSE_BRACE_EXPRESSION__
      end
    end

    def _add_normal_string s
      @_a.push Normal_String___.new s
      KEEP_PARSING_
    end

    def __parse_magic

      d = @_scn.scan DIGIT_RX__
      if d
        ___on_digit d
      else
        _expected :digit
      end
    end

    def ___on_digit d

      m_a = []
      ok = true

      while @_scn.skip DOT_RX__
        name_s = @_scn.scan METHOD_NAME_RX__
        if name_s
          m_a.push name_s
        else
          ok = _expected :method_name
          break
        end
      end

      if ok
        ___parse_end_of_magic m_a, d
      else
        ok
      end
    end

    def ___parse_end_of_magic m_a, d

      @_scn.skip WHITE_RX_

      if @_scn.skip CLOSE_RX_
        ___on_end_of_magic m_a, d
      else
        _expected '.', CLOSE_BRACE_EXPRESSION__
      end
    end

      DOT_RX__ = /\./

      METHOD_NAME_RX__ = /[a-z_]+/

    def ___on_end_of_magic s_a, d

      repl_expr = Self_::Build_replace_expression__.with(

        :capture_identifier, d,
        :method_call_chain, s_a,
        :functions_dir, @functions_dir,
        & @_oes_p )

      if repl_expr
        @_a.push repl_expr ; ACHIEVED_
      else
        repl_expr
      end
    end

    def _expected * x_a

      @_oes_p.call :replace_function_parse_error do
        Self_::Parse_error__[ * x_a, @_scn ]
      end
      UNABLE_
    end

      DIGIT_RX__ = /\d+/

      class Normal_String___

        def initialize s
          @string = s
          @as_text = s.gsub ESCAPE_RX__ do
            ESCAPE_OK_MAP__.fetch $~[ 1 ].getbyte 0
          end
        end

        ESCAPE_RX__ = /([\n\t\\])/

        ESCAPE_OK_MAP__ = {
          '\\'.getbyte( 0 ) => "\\\\",
          "\n".getbyte( 0 ) => "\\n",
          "\t".getbyte( 0 ) => "\\t" }

        attr_reader :as_text

        def call md
          @string
        end

        def marshal_dump
          @as_text
        end
      end

      CLOSE_BRACE_EXPRESSION__ = '}}'.freeze

      CLOSE_RX_ = /}}/

    KEEP_PARSING_ = true

      OPEN_BRACE_EXPRESSON__ = '{{'.freeze

      Self_ = self

      WHITE_RX_ = /[[:space:]]+/

  end
end
