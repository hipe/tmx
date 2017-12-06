module Skylab::Basic

  module String

    class WordWrapper::Crazy < ::Enumerator::Yielder  # :+[#033].

    def initialize p, set_indent_p, flush_p
      @flush_p = flush_p ; @set_indent_p = set_indent_p
      super( & p )
    end

    def indent= x
      @set_indent_p[ x ]
    end

    def flush
      @flush_p[]
    end

    word_stream_via_styled_string = nil
    word_stream_via_plain_string = nil
    lib = nil

    define_singleton_method :curry, ( -> do

      build_word_pool = build_indenter = nil
      build_wrapping_indenter = -> indent_s, width_d, downstream_y do
        process_input_line = flush_full_lines = flush_hard = nil
        indenter = build_indenter[ indent_s, downstream_y ]
        word_pool = build_word_pool[ width_d - indent_s.length ]
        windenter = new -> input_line do
          if input_line
            process_input_line[ input_line ]
          else
            flush_hard[]
            indenter << input_line
          end
        end, -> s do # 'indent='
          if word_pool.buffered_word_count.zero?
            indenter.change_indent s
          else
            indenter.change_subsequent_indent s
          end
          word_pool.change_cols( width_d - s.length ) ; s
        end, -> do  # 'flush'
          flush_hard[]
        end

        process_input_line_nomally = -> input_line do

          input_line or fail 'never'

          st = if lib::SIMPLE_STYLE_RX =~ input_line
            word_stream_via_styled_string[ input_line ]
          else
            word_stream_via_plain_string[ input_line ]
          end

          begin
            word = st.gets
            word || break
            word_pool << word
            redo
          end while above

          flush_full_lines[]
        end

        process_input_line = -> input_line do
          lib = Home_.lib_.zerk::CLI::Styling
          process_input_line = process_input_line_nomally
          process_input_line[ input_line ]
        end

        flush_hard = -> do
          flush_full_lines[]
          fragment_s = word_pool.flush_any_line_in_progress
          fragment_s and indenter << fragment_s ; nil
        end

        flush_full_lines = -> do
          while (( line = word_pool.gets ))
            indenter << line
          end ; nil
        end

        windenter
      end

      _WORD_SEPARATOR_RX = /[ ]/

      _LEADING_PUNCT_RX = /\A[.,:;!?]/

      _Word = ::Struct.new :any_style_d, :string, :is_space

      _SPACE_WORD = _Word.new nil, SPACE_, true

      no_style = [:no_style]

      word_stream_via_styled_string = -> str do

        chunk_st = lib::ChunkStream_via_String[ str ]

        word_st = nil ; p = nil ; main = nil
        other_guy = -> do
          w = word_st.gets
          if w
            w
          else
            p = main
            p[]
          end
        end

        main = -> do
          chunk = chunk_st.gets
          if chunk
            styles = chunk.styles
            if 1 == styles.length
              if no_style == styles
                word_st = word_stream_via_plain_string[ chunk.string ]
                p = other_guy
                p[]
              else
                _Word.new(
                  lib::INTEGER_VIA_SYMBOL_HASH.fetch( styles.fetch 0 ),
                  chunk.string
                )
              end
            else
              self._THIS_IS_THE_WORST
            end
          end
        end

        p = -> do
          s = chunk_st.gets
          if s
            p = main
            if s.length.zero?
              p[]
            else
              _Word.new nil, s
            end
          end
        end

        Common_.stream do
          p[]
        end
      end

      word_stream_via_plain_string = -> str do
        Stream_.call( str.split _WORD_SEPARATOR_RX ).map_by do |s|
          _Word.new nil, s
        end
      end

      word_pool_class = nil
      build_word_pool = -> local_width_limit do
        word_pool_class[].new local_width_limit
      end

      word_pool_class = -> do
        cls = ::Class.new.class_exec do
          def initialize cols
            @cols = sanitize cols ; @line_a = [] ; @width = 0 ; @word_a = []
          end
        private
          def sanitize cols
            5 > cols ? 80 : cols
          end
        public
          def << word
            @word = word
            @wlen = word.string.length
            @wlen.zero? or accept ; nil
          end
        private
          define_method :accept do
            @next_width = @width + @wlen
            if @word_a.length.nonzero? && _LEADING_PUNCT_RX !~ @word.string
              @sep = _SPACE_WORD ; @next_width += 1
            else
              @sep = nil
            end
            place ; nil
          end
          def place
            case @next_width <=> @cols
            when -1 ; add_word
            when  0 ; add_word_and_flush_line
            when  1 ; flush_line_and_add_word
            end     ; nil
          end
          def flush_line_and_add_word
            if @width.zero?
              add_word_and_flush_line  # rather than breaking up an indiv. word
            else
              flush_line ; add_word
            end
          end
          def add_word_and_flush_line
            add_word ; flush_line
          end
          def add_word
            w = @wlen
            if @word_a.length.nonzero? and @sep
              w += @sep.string.length
              @word_a << @sep
            end
            @word_a << @word
            @width += w ; nil
          end
          def flush_line
            _line = get_flushed_line
            @line_a << _line ; nil
          end
          def get_flushed_line
            @word_a.length.zero? and fail 'sanity'
            line = @word_a.map do |word|
              if (( d = word.any_style_d ))
                "\e[#{ d }m#{ word.string }\e[0m"
              else
                word.string
              end
            end.join EMPTY_S_
            @word_a.clear ; @width = 0
            line
          end
        public
          def gets
            @line_a.length.nonzero? and @line_a.shift
          end
          def change_cols d
            case d <=> @cols
            when -1 ; reduce_cols d
            when  1 ; increase_cols d
            end ; nil
          end
        private
          def reduce_cols d
            d = sanitize d
            case @width <=> d
            when -1 ; @cols = d
            when  0 ; @cols = d ; flush_line
            when  1 ; reduce_cols_when_under_current_word_buffer d
            end ; nil
          end
          def increase_cols d
            @cols = d ; nil
          end
          def reduce_cols_when_under_current_word_buffer d  # #todo
            stack = [] ; d_ = 0
            begin
              stack << ( word = @word_a.pop )
              d_ += word.string.length
              if @word_a.length.nonzero? and @word_a.last.is_space
                sp = @word_a.pop  # not placed on stack
                d_ += sp.string.length
              end
              curr_width = @width - d_
            end while curr_width > d
            @word_a.length.nzero? or flush_line
            stack.each do |word_|
              @word = word_
              accept
            end ; nil
          end
        public
          def buffered_word_count
            @word_a.length
          end
          def flush_any_line_in_progress
            if @word_a.length.nonzero?
              get_flushed_line
            end
          end
          self
        end
        word_pool_class = -> { cls } ; cls
      end

      build_indenter = -> ind_s, lowstream_y do
        ind = -> { ind_s }
        e = ::Enumerator::Yielder.new do |midstream_s|
          if midstream_s
            lowstream_y << "#{ ind[] }#{ midstream_s }"
          else
            lowstream_y << midstream_s
          end ; e
        end
        e.singleton_class.send :alias_method, :def, :define_singleton_method
        e.def :change_indent do |s|
          ind_s = s ; nil
        end
        e.def :change_subsequent_indent do |s|
          one_time = ind_s ; ind_s = s
          ind = -> do
            ind = -> { ind_s }
            one_time
          end ; nil
        end
        e
      end

      build_wrapping_indenter

    end ).call

    end
  end
end
# #history: get rid of ancient sexp techinques, old parse styles
