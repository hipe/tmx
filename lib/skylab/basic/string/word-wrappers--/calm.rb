module Skylab::Basic

  module String

    class Word_Wrappers__::Calm  # see [#033]

      Callback_::Actor.methodic self, :properties,

        :aspect_ratio,  # IFF this, we engage layout engine of same
        :downstream_yielder,
        :first_line_margin,
        :first_line_margin_width,  # only when etc
        :margin,
        :width

      def initialize & edit_p

        @aspect_ratio = nil
        @do_add_newlines = false
        @do_margin_on_first_line = true
        @first_line_margin = nil
        @first_line_margin_width = nil
        @_input_shape = nil
        @margin = nil
        instance_exec( & edit_p )

        if @aspect_ratio
          extend String_::Fit_to_Aspect_Ratio_::Layout_Engine_Methods
        else
          extend Streaming_Layout_Engine_Methods___
        end

        init_layout_engine_
      end

    private

      def add_newlines=

        @do_add_newlines = true
        KEEP_PARSING_
      end

      def input_string=

        x = iambic_property
        if x
          if @_input_shape
            raise ::ArgumentError
          end
          @_input_shape = :string
          @input_string = x
        end
        KEEP_PARSING_
      end

      def input_words=

        x = iambic_property
        if x
          if @_input_shape
            raise ::ArgumentError
          end
          @_input_shape = :words
          @input_words = x
        end
        KEEP_PARSING_
      end

      def skip_margin_on_first_line=

        @do_margin_on_first_line = false
        KEEP_PARSING_
      end

    public

      def execute  # only for when this is used as a pure actor (function)

        send :"__execute_via__#{ @_input_shape }__"
      end

      def __execute_via__string__

        self << remove_instance_variable( :@input_string )
        flush
      end

      def __execute_via__words__

        a = remove_instance_variable :@input_words
        a.each do | s |
          self << s
        end
        flush
      end

      Parse_Context_Methods = ::Module.new

      module Streaming_Layout_Algorithm_Methods
        include Parse_Context_Methods
      end

      module Streaming_Layout_Engine_Methods___
      private

        def init_layout_engine_

          init_context_
          init_tokenization_
          __via_tokenization_init_margination
          NIL_
        end

      public

        def << mixed_string

          @reinit_tokenizer_[ mixed_string ]

          begin

            _more = @tokenizer_.unparsed_exists
            _more or break

            _stay = send :"at__#{ @tokenizer_.step.symbol }__token"
            _stay or break
            redo
          end while nil

          self
        end

        def flush  # assume current width is inaccurate

          remove_trailing_spaces_

          if @tokens_.length.nonzero?

            into_downstream_yielder_flush_these_mutable_tokens_ @tokens_
            @tokens_.clear

            if @_add_margin_on_subsequent_lines

              @tokens_.push @_margin_token
              @current_width_ = @_margin_width

            else
              @current_width_ = 0
            end

            change_context_ :margin_end_
          end

          @downstream_yielder
        end

        include Streaming_Layout_Algorithm_Methods
      end

      module Streaming_Layout_Algorithm_Methods

        def init_tokenizer_via_stream_ st

          @tokenizer_ = Risky_Tokenizer__.new
          @tokenizer_.init_via_stream st
          NIL_
        end

        def at__dash__token

          # this is not for "hyphen"-style dashes, only for those that
          # came at the beginning of input or after a space.. [sg]
          # it's also a good example of the general pattern here

          width = @current_width_ + _width_of_current_token

          accept_current_tokens = if _next_token_is :word  # e.g " a -> b " [sg]

            width += @tokenizer_.next_step.length

            -> do
              _accept_current_token
              _accept_current_token
            end
          else
            -> do
              _accept_current_token
            end
          end

          case @width <=> width

          when 1  # under
            accept_current_tokens[]

          when -1  # over
            flush
            accept_current_tokens[]

          when 0  # money
            accept_current_tokens[]
            flush
          end

          KEEP_PARSING_
        end

        def at__word__token

          # :+#special-logic: add space between words that have none
          # :+#special-logic: don't break between a word and its next dash

          width = @current_width_ + _width_of_current_token

          if _context_is :word
            add_space_if_necessary = -> do
              _accept_token Space_token__[]
            end
            width += 1
          else
            add_space_if_necessary = EMPTY_P_
          end

          if _next_token_is :dash
            had_dash = true
            width += 1
          end

          accept_word = -> do
            _accept_current_token
            if had_dash
              _accept_current_token
            end
          end

          case @width <=> width

          when 1  # under

            add_space_if_necessary[]
            accept_word[]

          when -1  # over

            flush
            accept_word[]

          when 0  # money

            add_space_if_necessary[]
            accept_word[]
            flush

          end

          KEEP_PARSING_
        end

        def at__spaces__token

          # :+#special-logic: for now, any one or more contiguous spaces
          # tokens who are one character in length and would occur at the
          # beginning of the line are disregarded.

          if _context_is :margin_end_

            if 1 < _width_of_current_token
              _consider_space
            else
              _advance_by_one_token
            end
          else
            _consider_space
          end
        end

        def _consider_space

          # :+#special-logic: add a spaces to the beginning of a line IFF
          # it is greater than 1 in width

          width = @current_width_ + _width_of_current_token

          case @width <=> width

          when 1  # under

            _accept_current_token

          when -1, 0  # over, money

            flush

            if 1 < _width_of_current_token
              _accept_current_token
            else
              _advance_by_one_token
            end
          end

          KEEP_PARSING_
        end

        # ~ token reflection & lookahead

        def _next_token_is sym

          if @tokenizer_.has_next_step

            sym == @tokenizer_.next_step.symbol
          end
        end

        def _width_of_current_token

          @tokenizer_.step.length
        end

        # ~ token acceptance

        def _accept_current_token

          _tok = @tokenizer_.gets_one_token
          _accept_token _tok
        end

        def _advance_by_one_token

          @tokenizer_.advance_by_one_token
          KEEP_PARSING_  # convenience
        end

        def _accept_token tok_o

          @current_width_ += tok_o.length
          @tokens_.push tok_o
          @_context = tok_o.symbol
          NIL_
        end

        def remove_trailing_spaces_

          # :+#special-logic: life is easiest if we strip the not-
          # artificially added but now not needed trailing space here..

          if _context_is :spaces
            if 1 == @tokens_.last.length
              @tokens_.pop
            end

          elsif _context_is :margin_end_

            if 1 == @tokens_.length

              _ok = if :_margin_ == @tokens_.first.symbol
                true
              elsif :_first_margin_ == @tokens.first.symbol
                true
              end
              if _ok
                @tokens_.pop
              else
                self._SANITY
              end
            end
          end
          NIL_
        end
      end

      module Parse_Context_Methods

        def init_context_

          @_context = nil
          NIL_
        end

        def _context_is sym

          sym == @_context
        end

        def change_context_ sym

          @_context = sym
          NIL_
        end

        def remove_context_

          remove_instance_variable :@_context
          NIL_
        end
      end

      # ~ "subsystem" initializers private for now but may be exposed

      def init_tokenization_

        @reinit_tokenizer_ = -> str do

          @reinit_tokenizer_ = -> str_ do
            _reinit_tokenizer_via_string str_
          end

          _init_tokenizer_via_string str
        end

        @tokens_ = []
        NIL_
      end

      def _init_tokenizer_via_string str

        @tokenizer_ = Risky_Tokenizer__.new
        @tokenizer_.init_via_string str
        NIL_
      end

      def _reinit_tokenizer_via_string str

        @tokenizer_.change_string str
        NIL_
      end

      def __via_tokenization_init_margination

        if @margin

          @_add_margin_on_subsequent_lines = true
          @_margin_width = @margin.length
          @_margin_token = Token__.new @margin, :_margin_

        else

          @_add_margin_on_subsequent_lines = false

        end

        if @first_line_margin_width

          # then we assume we are not showing it, only using it
          @current_width_ = @first_line_margin_width

        elsif @first_line_margin

          @current_width_ = @first_line_margin.length

          if @do_margin_on_first_line

            _tok = Token__.new @first_line_margin, :_first_margin_
            @tokens_.push _tok
          end

        elsif @margin

          if @do_margin_on_first_line

            @current_width_ = @_margin_width
            @tokens_.push @_margin_token
          else

            # it means don't count the margin towards width on 1st line either

            @current_width_ = 0
          end
        else

          @current_width_ = 0
        end

        NIL_
      end

      def into_downstream_yielder_flush_these_mutable_tokens_ tok_o_a

        if @do_add_newlines
          tok_o_a.push Newline_token___[]
        end

        @downstream_yielder << ( tok_o_a.map( & :string ) * EMPTY_S_ )

        NIL_
      end

      # ~

      class Risky_Tokenizer__

        def initialize

          @_cache = []
          @_states = STATES___
        end

        def init_via_string string

          @_scn = Basic_.lib_.string_scanner string
          _via_string_scanner_reinit_step_stream
          NIL_
        end

        def change_string string

          _clear
          @_scn.string = string
          _via_string_scanner_reinit_step_stream
          NIL_
        end

        def init_via_stream st

          @step_stream = st
          NIL_
        end

        def reinit_via_stream st

          _clear
          @step_stream = st
          NIL_
        end

        def _clear
          @_cache.clear
          NIL_
        end

        def has_next_step

          if unparsed_exists
            if 1 == @_cache.length
              x = @step_stream.gets
              if x
                @_cache.push x
                true
              else
                false
              end
            else
              true
            end
          end
        end

        def next_step
          @_cache.fetch 1
        end

        def gets_one_token

          step = @_cache.fetch 0
          @_cache[ 0, 1 ] = EMPTY_A_
          step.to_token
        end

        def advance_by_one_token

          @_cache.length.zero? and self._SANITY
          @_cache[ 0, 1 ] = EMPTY_A_
          NIL_
        end

        def unparsed_exists

          if @_cache.length.zero?
            x = @step_stream.gets
            if x
              @_cache.push x
              true
            else
              false
            end
          else
            true
          end
        end

        def step
          @_cache.fetch 0
        end

        attr_reader :step_stream

        def _via_string_scanner_reinit_step_stream

          scn = @_scn
          state = @_states.fetch :start
          string = scn.string

          @step_stream = Callback_.stream do

            if scn.eos?

              # :+#special-logic: the empty string as input has no effect

              NIL_
            else

              prev_d = scn.pos

              state_ = @_states.fetch state.best_guess
              d = scn.skip state_.rx
              if d

                state = state_

              else

                state_ = @_states.fetch state.second_guess
                d = scn.skip state_.rx
                if d

                  state = state_

                else

                  state_ = @_states.fetch state.final_guess
                  d = scn.skip state_.rx
                  if d

                    state = state_

                  else

                    self._RISKY
                  end
                end
              end

              Step___.new d, state.symbol do
                string[ prev_d, d ]
              end
            end
          end
          NIL_
        end

        o = State___ = ::Struct.new(
          :symbol,
          :rx,
          :best_guess,
          :second_guess,
          :final_guess )

        STATES___ = {

          start: o[ :start, nil,
            :word,
            :spaces,
            :dash ],

          word: o[ :word,
            /(?:[^[:space:]-]|-{2,})+/,
            :spaces,
            :dash ],

          spaces: o[ :spaces,
            /[[:space:]]+/,
            :word,
            :dash ],

          dash: o[ :dash,
            /-(?!-)/,
            :word,
            :spaces ]
        }
      end

      class Step___

        def initialize d, sym, & p

          @length = d
          @symbol = sym
          @_p = p
        end

        attr_reader :length, :symbol

        def to_token
          Token__.new @_p[], @symbol
        end
      end

      class Token__

        def initialize s, sym=nil

          @length = s.length
          @string = s
          @symbol = sym
        end

        attr_reader :length, :string, :symbol

        def to_token
          self
        end
      end

      Newline_token___ = Callback_.memoize do
        Token__.new NEWLINE_, :xx
      end

      Space_token__ = Callback_.memoize do
        Token__.new SPACE_, :spaces
      end
    end
  end
end
