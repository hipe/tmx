module Skylab::Basic

  module String

    class Word_Wrappers__::Crazy < ::Enumerator::Yielder

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

    define_singleton_method :curry, ( -> do

      build_word_scanner = build_word_pool = build_indenter = nil
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
        process_input_line = -> input_line do
          input_line or fail 'never'
          _sx = Basic_::Lib_::CLI_lib[].parse_styles input_line
          _sx ||= [[ :string, input_line ]]
          scn = build_word_scanner[ _sx ]
          while (( word = scn.gets ))
            word_pool << word
          end
          flush_full_lines[]
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

      scan_string = scan_style = skip_final_style = nil
      build_word_scanner = -> sx do
        buffer_a = []
        if sx
          begin
            befor = buffer_a.length
            if :string == sx[ 0 ][ 0 ]
              string = scan_string[ sx ]
              word_a = string.split _WORD_SEPARATOR_RX
              word_a.each do |s|
                buffer_a << _Word.new( nil, s )
              end
              sx.length.zero? and break
            end
            if :style == sx[ 0 ][ 0 ]
              _style_d = scan_style[ sx ]
              _string = scan_string[ sx ]
              skip_final_style[ sx ]
              _word = _Word.new _style_d, _string
              buffer_a << _word
              sx.length.zero? and break
            end
            befor == buffer_a.length and fail "unexpected '#{ sx[ 0 ][ 0 ] }'"
          end while true
        end
        p = -> do
          buffer_a.shift
        end
        class << p
          alias_method :gets, :call
        end ; p
      end
      scan_string = -> sx do
        i, x = sx.shift
        :string == i or fail "sanity - expected 'string' had '#{ i }'"
        x
      end
      scan_style = -> sx do
        i, x = sx.shift
        :style == i or fail "sanity - expected 'style' had '#{ i }'"
        x
      end
      skip_final_style = -> sx do
        d = scan_style[ sx ]
        d.zero? or fail "sanity - expected '0' had '#{ d }'" ; nil
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
