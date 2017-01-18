module Skylab::Zerk

  class InteractiveCLI

  class List_Interpretation_Adapter___ < Common_::Monadic  # :[#008]..

    # #open after incubation (which will be after [#009]), de-dup this
    # with [#sy-029] OGDL which should be similar.. or don't

    def initialize s, & oes_p
      @_scn = Home_.lib_.string_scanner.new s
      @_oes_p = oes_p
    end

    def execute

      st = -> do
        @_p[]
      end

      @_when_begin = method :___when_begin

      @_p = @_when_begin
      @_result = []

      begin
        kn = st.call
        if kn
          @_result.push kn.value_x
          redo
        end
        break
      end while nil

      @_result
    end

    def ___when_begin
      _skip_white
      if _at_end_of_string
        _finish
      elsif _parse_and_store_any_quote
        if _at_end_of_string
          _error_no_closing_quote
        else
          _parse_quoted_content
        end
      else
        _parse_unquoted_content
      end
    end

    def _parse_and_store_any_quote
      s = _parse_any_quote
      if s
        @_last_quote_style = QUOTE_STYLE___.fetch s
        ACHIEVED_
      else
        NOTHING_
      end
    end

    def _parse_any_quote
      @_scn.scan EITHER_QUOTE_RX___
    end

    EITHER_QUOTE_RX___ = /['"]/

    QUOTE_STYLE___ = {
      "'" => :single,
      '"' => :double,
    }

    QUOTE_STRING___ = QUOTE_STYLE___.invert

    def _parse_unquoted_content

      s = _write_unquoted_content_to_buffer ""
      if s
        Common_::Known_Known[ s ]
      else
        __error_unexpected_character_in_unquoted_string
      end
    end

    def _parse_quoted_content
      s = _write_quoted_content_to_buffer ""
      if s
        if ___close_quote
          Common_::Known_Known[ s ]
        else
          _error_no_closing_quote
        end
      else
        s  # eg.escape character w/ nothing after it (covered)
      end
    end

    def ___close_quote

      @_scn.skip CLOSE_QUOTE___.fetch @_last_quote_style
    end

    CLOSE_QUOTE___ = {
      single: /'/,
      double: /"/,
    }

    def _write_unquoted_content_to_buffer buffer

      # assume head is not space, not quote, not EOS

      d = @_scn.pos
      w = @_scn.skip PLAIN_RX___
      if w
        buffer.concat @_scn.string[ d, w ]
        @_scn.pos = d + w
        buffer
      end
    end

    PLAIN_RX___ = /[^ \t'",\\]+/

    def _write_quoted_content_to_buffer buffer

      # assume head is not EOS

      ok = true
      rx = ETC___.fetch @_last_quote_style

      begin
        len = buffer.length
        d = @_scn.pos

        w = @_scn.skip rx
        if w
          buffer.concat @_scn.string[ d, w ]
          @_scn.pos = d + w
        end

        w = @_scn.skip BACKSLASH_RX___
        if w
          s = @_scn.getch
          if s
            # (here you could..)
            buffer.concat s
          else
            @_scn.pos = @_scn.pos - w
            __error_escape_character_with_nothing_after_it
            ok = false
            break
          end
        end

        if len == buffer.length  # e.g the empty quoted strings
          break
        end

        redo
      end while nil

      ok ? buffer : ok
    end

    BACKSLASH_RX___ = /\\/

    ETC___ = {
      double: /[^\\"]+/,
      single: /[^\\']+/,
    }

    def _skip_white
      @_scn.skip WHITE_RX___ ; nil
    end

    def _at_end_of_string
      @_scn.eos?
    end

    # --

    def __error_escape_character_with_nothing_after_it

      @_oes_p.call( * THESE__, :escape_character_with_nothing_after_it ) do |y|
        y << "escape character with nothing after it"
      end
      _errored
    end

    def _error_no_closing_quote
      sym = @_last_quote_style
      @_oes_p.call( * THESE__, :unclosed_quote ) do |y|
        y << "expecting #{ QUOTE_STRING___.fetch( sym ).inspect }."
      end
      _errored
    end

    def __error_unexpected_character_in_unquoted_string

      char = @_scn.peek 1
      @_oes_p.call( * THESE__, :unexpected_character_in_unquoted_string ) do |y|
        y << "unexpected character in unquoted string: #{ char.inspect }"
      end
      _errored
    end

    THESE__ = [ :error, :expression, :list_parse_error ]

    def _errored
      @_result = UNABLE_
      UNABLE_
    end

    # --

    def _finish
      @_p = nil
      NOTHING_
    end

    WHITE_RX___ = /[ \t]/
  end

  end
end
