module Skylab::Human

  class PhraseAssembly  # :[#046] (1 mentor)

    # this is *the* suite of methods (implemented as a session) for building
    # a "phrase" (string) from a collection of "tokens" while managing the
    # problem of having to know when to add a separator space when not all
    # elements are guaranteed to be present, and some elements don't receive
    # a prefixed space (like a comma) and some elements don't receive an
    # affixed or prefixed space (like a hyphen).
    #
    #   • #open redudnant with ANCIENT [#ba-033] at #interlude-2 we might
    #      gather it in..
    #
    #   • currently these "tokens" are internally implemented as a
    #     specialized subset of "sexp"
    #
    #   • in methods where there is an `add_FOO` and counterpart
    #     `add_any_FOO`, the former takes an argument that must be present
    #     and in the latter form, if the argument is false-ish it is
    #     equivalent to having not called the method.
    #
    #   • if no tokens have been added to the tokens buffer when «whatever»
    #     is called, `nil` is the result.
    #
    #   • normally, produced strings will not begin nor end with an added
    #     space. (but this can be altered..)
    #
    # additionally we are beginning to add support for the rendering
    # of [#049] sexps..
    #
    #   • there's no reason to use the subject unless the assembly involves
    #     possibly more than one token or the rendering of a sexp.
    #
    # for simplicity of implementation, it is best that the lifetime of a
    # single instance of this exist one-to-one with the construction of a
    # single "phrase assembly":
    #
    #   • when we tried to add a re-entrant `flush` it complicated things
    #     substatially.
    #
    #   • when we tried to make this streaming it was awful too
    #
    #   • if you want flush-type behavior try to use this at the sub-flush
    #     level..
    #
    #   • all this is notwithstanding any dup-and-mutate-type behavior
    #     we might take on.

    class << self

      def [] * s_a  # experimental high-level convenience stringifier
        o = begin_phrase_builder
        s_a.each do |s|
          o.add_any_string s
        end
        o.flush_to_string
      end

      def begin_phrase_builder
        new.__init_phrase_builder
      end

      private :new
    end  # >>

    def __init_phrase_builder

      @_add_m = :__add_first_token
      @_has_nonzero_tokens = false
      @_sexp_via_finish_m = :_sexp_via_finish_when_empty
      @_2nd_sexp_via_finish_m = :__sexp_via_finish_when_non_empty
      @previous_sexp = nil
      self
    end

    def add_any_sexp sexp
      if sexp
        _add sexp
        NIL_
      end
    end

    def add_any_string s
      if s
        add_string s
      end
      NIL_
    end

    def add_any_string_as_is s
      if s
        add_string_as_is s
      end
      NIL_
    end

    def add_string s
      if COMMON_PUNCTUATION___[ s.getbyte 0 ]
        _add_common_punctuation s
      else
        _add [ :wordish, s ]
      end
    end

    COMMON_PUNCTUATION___ = ::Hash[ ',.?!'.each_byte.map { |d| [d, true] } ]

    def add_space_if_necessary
      if @_has_nonzero_tokens && @_tokens.last != Lazy_Space__[]
        add_lazy_space
      end
    end

    def add_lazy_space
      _add Lazy_Space__[]
    end

    def add_comma
      _add Comma___[]
    end

    def add_period
      _add_common_punctuation '.'
    end

    def add_newline
      add_string_as_is NEWLINE_
    end

    def _add_common_punctuation s
      _add [ :trailing, s ]
    end

    def add_string_as_is s
      _add [ :as_is, s ]
    end

    def _add trueish_x
      send @_add_m, trueish_x
    end

    def __add_first_token o
      @_has_nonzero_tokens = true
      @_tokens = [ o ]
      @_add_m = :___add_subsequent_token
      @_sexp_via_finish_m = remove_instance_variable :@_2nd_sexp_via_finish_m
      NIL_
    end

    def ___add_subsequent_token o
      @_tokens.push o
      NIL_
    end

    attr_writer(
      :previous_sexp,
    )

    # --

    def flush_to_string
      if @_has_nonzero_tokens
        express_into ""
      end
    end

    def express_into y
      sx = sexp_via_finish
      if sx
        y << sx.fetch( 1 )
      end
      y
    end

    def sexp_via_finish  # might be nil
      send @_sexp_via_finish_m
    end

    def _sexp_via_finish_when_empty
      NOTHING_
    end

    def __sexp_via_finish_when_non_empty

      _st = _token_stream_via_finish

      _prev_token = @previous_sexp || Head_token___[]

      Sexp_via_non_empty_token_stream__[ _prev_token, _st ]
    end

    def _token_stream_via_finish
      Common_::Polymorphic_Stream.via_array remove_instance_variable :@_tokens
    end

    Lazy_Space__ = Lazy_.call do

      # expressed as a space IFF it's the non-first token, otherwise adds
      # the empty string to the string. (this token may not work as expected
      # if more than one are added contiguously.)

      [ :wordish, EMPTY_S_ ]
    end

    Comma___ = Lazy_.call do
      [ :trailing, ','.freeze ]
    end

    Head_token___ = Lazy_.call do
      [ :as_is, nil ]
    end

    # --

    rx = nil
    Guess_sexp_via_string = -> s do

      rx ||= /\A(?<leading>[ ](?!\z))?  (?<body>.*[^ ]|)  (?<trailing>[ ])?\z/x

      md = rx.match s

      _sym = if md[ :leading ]
        if md[ :trailing ]
          :wordish
        else
          :goofy
        end
      elsif md[ :trailing ]
        :trailing
      else
        :as_is
      end

      [ _sym, md[ :body ] ]
    end

    rx_ = nil
    Sentence_string_head_via_words = -> s_a do

      rx_ ||= /\A[:,]/  # etc  #open [#051]

      st = Common_::Polymorphic_Stream.via_array s_a

      s_a_ = [ st.gets_one ]
      while st.unparsed_exists
        s = st.gets_one
        if rx_ !~ s
          s_a_.push SPACE_
        end
        s_a_.push s
      end
      s_a_ * EMPTY_S_
    end

    followed_by_space = nil
    preceded_by_space = nil

    word_chunk_stream_via_sexp_stream = nil
    string_via_nonempty_chunk = nil

    Word_string_stream_via_sexp_stream = -> st do

      _st = word_chunk_stream_via_sexp_stream[ st ]
      _st.map_by( & string_via_nonempty_chunk )
    end

    word_chunk_stream_via_sexp_stream = -> st do

      main_gets = -> do
        st.gets
      end
      gets = main_gets

      peek = nil
      main_peek = -> do
        sx = main_gets[]
        if sx
          peek = nil
          gets = -> do
            gets = main_gets
            peek = main_peek
            sx
          end
          sx
        else
          gets = EMPTY_P_ ; peek = nil
        end
      end
      peek = main_peek

      Common_.stream do

        galley = nil
        add = -> sx do
          galley = [ sx ]
          add = -> sx_ do
            galley.push sx_
          end
        end

        begin
          sx = gets[]
          sx or break
          if :the_empty_sexp == sx.first
            redo
          end
          add[ sx ]
          if ! followed_by_space[ sx.first ]
            redo
          end
          sx = peek[]
          if ! sx
            break
          end
          if preceded_by_space[ sx.first ]
            break
          end
          redo
        end while nil

        galley
      end
    end

    string_via_nonempty_chunk = -> ch do

      _st = Common_::Polymorphic_Stream.via_array ch

      _ = Sexp_via_non_empty_token_stream__[ Head_token___[], _st ]

      _.fetch 1
    end

    Sexp_via_non_empty_token_stream__ = -> prev_token, st do

      s = ""
      tok = st.gets_one
      first_token = tok
      begin

        if Add_space_between[ prev_token, tok ]
          s << SPACE_
        end

        s << tok.fetch( 1 )

        if st.no_unparsed_exists
          break
        end

        prev_token = tok
        tok = st.gets_one

        redo
      end while nil

      _sym = if preceded_by_space[ first_token.first ]
        if followed_by_space[ tok.first ]
          :wordish
        else
          :goofy
        end
      elsif followed_by_space[ tok.first ]
        :trailing
      else
        :as_is
      end

      [ _sym, s ]
    end

    Add_space_between = -> sx, sx_ do

      followed_by_space[ sx.first ] && preceded_by_space[ sx_.first ]
    end

    # --

    load_them = nil

    followed_by_space = -> sym do
      load_them[]
      followed_by_space[ sym ]
    end

    preceded_by_space = -> sym do
      load_them[]
      preceded_by_space[ sym ]
    end

    load_them = -> do

      load_them = nil

      preceded_by_space = {
        as_is: false,
        goofy: true,
        wordish: true,
        trailing: false,
      }.method :fetch

      followed_by_space = {
        as_is: false,
        goofy: false,
        wordish: true,
        trailing: true,
      }.method :fetch
    end
  end
end
