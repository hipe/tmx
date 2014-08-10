module Skylab::Snag

  module Models::Hashtag

    class << self
      def parse s
        Scan_Maker__.new( s ).to_a
      end
      def scanner s
        Scan_Maker__.new( s ).to_scanner
      end
    end

    class Scan_Maker__
      def initialize str
        @str = str
      end
      def to_a
        scn = to_scanner ; y = [] ; x = nil
        y.push x while x = scn.gets ; y
      end
      def to_scanner
        _kernel = Scan_Kernel__.new @str
        Callback_::Scn.new( & _kernel.method( :gets ) )
      end
    end

    class Scan_Kernel__
      def initialize str
        @queue = []
        @scn = Snag_::Library_::StringScanner.new str
      end
      def gets
        if @queue.length.nonzero?
          @queue.shift
        elsif ! @scn.eos?
          step
        end
      end
    private
      def step
        @str = @scn.scan NOT_HASHTAG_RX__
        @tag = @scn.scan HASHTAG_RX__
        @str || @tag or raise say_parse_failure
        @str and process_string
        @tag and process_tag
        @queue.shift
      end
      _HASHTAG_ = '#[A-Za-z0-9]+(?:[-_][A-Za-z0-9]+)*'
      NOT_HASHTAG_RX__ = /(?:(?!#{ _HASHTAG_ }).)+/
      HASHTAG_RX__ = /#{ _HASHTAG_ }/

      def say_parse_failure
        "parse failure: #{ @scn.rest.inspect }"
      end

      def process_string
        @queue.push String__.new @str
      end

      def process_tag
        @queue.push Hashtag__.new @tag
        @sep = @scn.scan HASHTAG_NAME_VALUE_SEP_RX__
        @sep and process_sep ; nil
      end
      HASHTAG_NAME_VALUE_SEP_RX__ = /:[ ]*/

      def process_sep
        @queue.push Name_And_Value_Separator__.new @sep
        @value = @scn.scan HASHTAG_VALUE_RX__
        @value and process_value ; nil
      end
      HASHTAG_VALUE_RX__ = /[^[:space:]]+/

      def process_value
        @queue.push Value__.new @value ; nil
      end
    end

    class Piece__
      def initialize str
        @to_s = str ; nil
      end
      attr_reader :to_s
    end

    class String__ < Piece__
      def symbol_i
        :string
      end
    end

    class Hashtag__ < Piece__
      def symbol_i
        :hashtag
      end
      def get_stem_s
        @to_s[ 1..-1 ]
      end
    end

    class Name_And_Value_Separator__ < Piece__
      def symbol_i
        :hashtag_name_value_separator
      end
    end

    class Value__ < Piece__
      def symbol_i
        :hashtag_value
      end
    end
  end
end
