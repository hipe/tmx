module Skylab::Snag

  class Models::Hashtag < ::Class.new  # see [#056]

    class << self

      define_method :interpret_out_of_under, INTERPRET_OUT_OF_UNDER_METHOD_

      def interpret_simple_stream_from_string s
        Hashtag_Simple_Stream__.new s
      end

      def interpret_simple_stream_from__ begin_d, end_d, s, fly
        Hashtag_Simple_Stream__.new begin_d, end_d, fly, s
      end
    end  # >>

    TO_A_METHOD__ = -> do  # etc. redundant with etc

      a = []
      begin
        x = gets
        x or break
        a.push x
        redo
      end while nil
      a
    end

    class Value_Peeking_Simple_Stream___  # #note-25

      def initialize st
        @queue = []
        @st = st
      end

      def reinitialize beg, end_, s
        @queue.clear
        @st.reinitialize beg, end_, s
        NIL_
      end

      attr_reader :st  # hax

      define_method :to_a, TO_A_METHOD__

      def gets

        if @queue.length.zero?
          @st.gets
        else
          @queue.shift
        end
      end

      def peek_for_value

        if @queue.length.zero?
          x = @st.gets
          x and @queue.push x
        end

        if @queue.length.nonzero? and
            :hashtag_name_value_separator == @queue.first.nonterminal_symbol

          if 2 > @queue.length
            x = @st.gets
            x and @queue.push x
          end

          if 1 < @queue.length and :hashtag_value == @queue[1].nonterminal_symbol
            result = @queue[1]
          end
        end

        result
      end
    end

    class Hashtag_Simple_Stream__

      # NOTE parsing is always greedy. the 'end' term will be used only ..

      def initialize beg=nil, end_=nil, fly=nil, s

        @cls = fly || Hashtag___
        @end = end_ || s.length
        @queue = []
        @scn = Snag_::Library_::StringScanner.new s
        if beg
          @scn.pos = beg
        end
      end

      def reinitialize beg, end_, s

        @end = end_
        @queue.clear
        @scn.string = s
        @scn.pos = beg
        NIL_
      end

      attr_reader :scn  # hax

      def flush_to_puts_stream

        Callback_::Scanner::Puts_Wrapper.new self
      end

      def flush_to_value_peeking_stream

        Value_Peeking_Simple_Stream___.new self
      end

      define_method :to_a, TO_A_METHOD__

      def gets
        if @queue.length.nonzero?
          @queue.shift
        elsif @scn.pos < @end
          __step
        end
      end

      def __step

        @str = @scn.scan NOT_HASHTAG_RX__
        @tag_pos = @scn.pos
        @tag = @scn.scan HASHTAG_RX__

        if @str
          __process_string
          if @tag
            _process_tag
          end
          @queue.shift

        elsif @tag
          _process_tag
          @queue.shift

        elsif ! ( @end && @end <= @scn.pos )

          raise __say_parse_failure
        end
      end
      _HASHTAG_ = '#[A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*'
      NOT_HASHTAG_RX__ = /(?:(?!#{ _HASHTAG_ }).)+/
      HASHTAG_RX__ = /#{ _HASHTAG_ }/

      def __say_parse_failure
        "parse failure: #{ @scn.rest.inspect }"
      end

      def __process_string
        @queue.push String_Piece.new @str
      end

      def _process_tag
        @queue.push @cls.via_tag_position_and_tag_ @tag_pos, @tag
        @sep = @scn.scan HASHTAG_NAME_VALUE_SEP_RX__
        @sep and __process_sep ; nil
      end
      HASHTAG_NAME_VALUE_SEP_RX__ = /:[ ]*/

      def __process_sep
        @queue.push Name_And_Value_Separator__.new @sep
        @value = @scn.scan HASHTAG_VALUE_RX__
        @value and __process_value ; nil
      end
      HASHTAG_VALUE_RX__ = /[^[:space:],]+/

      def __process_value
        @queue.push Value__.new @value ; nil
      end
    end

    Piece__ = superclass

    class String_Piece < Piece__

      def nonterminal_symbol
        :string
      end

      alias_method :business_category_symbol, :nonterminal_symbol
        # life is easier and more efficient if we add this one line
    end

    Hashtag___ = self

    class Hashtag___  # descends from Piece__

      class << self
        alias_method :via_tag_position_and_tag_, :new
      end  # >>

      def initialize d, str
        super str
        @pos = d
      end

      attr_reader :pos

      def nonterminal_symbol
        :hashtag
      end

      def local_normal_name
        @lnn ||= get_stem_string.downcase.intern
      end

      def get_stem_string
        @to_s[ 1..-1 ]
      end
    end

    class Name_And_Value_Separator__ < Piece__

      def nonterminal_symbol
        :hashtag_name_value_separator
      end
    end

    class Value__ < Piece__

      def nonterminal_symbol
        :hashtag_value
      end
    end

    class Piece__

      def initialize str
        @to_s = str
      end

      attr_reader :to_s
    end
  end
end
