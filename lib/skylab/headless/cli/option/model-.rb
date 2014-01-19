module Skylab::Headless

  module CLI::Option

    class Model_

      # for reflection of options, not for parsing.

      class << self
        private :new
      end

      def self.new_flyweight
        allocate.instance_exec do
          @long_sexp = nil  # the micro-lith. everything stems from this.
          @args = nil  # ignore this here, used for compat. with other form
          self
        end
      end

      def self.new_semi_mutable_from_normal_name i
        m = Semi_Mutable_.new Local_normal_name_as_long[ i ]
        m.set_norm_short_str Local_normal_name_as_short_[ i ]
        m
      end

      Local_normal_name_as_short_ = -> i do
        "-#{ i[ 0 ] }"
      end

      def self.on *a, &b
        allocate.instance_exec do
          @norm_short_str = @long_sexp = @sexp = nil
          @args = a
          @block = b
          self
        end
      end

      #  ~ flyweight replacers - WARNING: ignorant of `args` & `block` ~

      def replace_with_long_rx_matchdata md
        @norm_short_str = @norm_long_str = nil
        @long_sexp and Option::Long_.release @long_sexp
        @long_sexp = Option::Long_.lease_from_matchdata md
        nil
      end

      def replace_with_switch sw
        replace_with_normal_args( ( sw.short.first if sw.short ),
          ( "#{ sw.long.first }#{ sw.arg }" if sw.long && sw.long.first ) )
        nil
      end

      def replace_with_normal_args norm_short_str, norm_long_str
        @long_sexp &&= Option::Long_.release @long_sexp
        @norm_short_str = norm_short_str || false
        @norm_long_str = norm_long_str || false
        nil
      end

      #   ~ readers (both direct & lazy / derived) & non-styled rendering ~

      def is_option  # #parameter-reflection-API
        true
      end

      def is_argument  # #parameter-reflection-API
        false
      end

      def get_args  # where available
        @args.dup
      end

      attr_reader :block

      def normal_short_string
        @norm_short_str.nil? && @args and puff
        @norm_short_str
      end

      def normal_long_string
        @long_sexp.nil? && @args and puff
        if @long_sexp
          ( @long_sexp.at :__, :no, :stem, :arg ) * EMPTY_SEP__
        else
          @long_sexp  # #meaningful-false
        end
      end

      def normalized_parameter_name   # #parameter-reflection-API
        if long_sexp
          Option::FUN.normize[ @long_sexp.stem ]
        else
          @long_sexp  # #meaningful-false
        end
      end

      def long_sexp
        if @long_sexp.nil?
          if @args
            puff
          else
            @long_sexp = if @norm_long_str
              Option::Long_.lease_from_matchdata(
                Option::Constants::LONG_RX.match( @norm_long_str ) )
            else
              false
            end
          end
        end
        @long_sexp
      end

      def as_parameter_signifier
        if long_sexp
          ( @long_sexp.at :__, :stem ) * EMPTY_SEP__
        else
          false
        end
      end

      def as_shortest_full_parameter_signifier
        y = [ ]
        if @norm_short_str
          y << @norm_short_str
          if long_sexp && @long_sexp.arg
            y << @long_sexp.arg
          end
        elsif long_sexp
          # (sure why not, have the entire monty)
          y << @long_sexp.at( :__, :no, :stem, :arg ).join( EMPTY_SEP__ )
        end
        y.length.nonzero? and y * EMPTY_SEP__
      end

      def as_longest_nonfull_signifier
        if long_sexp
          ( @long_sexp.at :__, :stem ) * EMPTY_SEP__
        else
          @norm_short_str
        end
      end

      def as_shortest_nonfull_signifier
        @norm_short_str
      end

      def sexp
        @sexp.nil? and puff
        @sexp
      end

      def short_fulls
        @sexp.nil? and puff
        if @sexp
          ::Enumerator.new do |y|
            @sexp.children( :short_full ).each do |sx|
              y << sx.last
            end
            nil
          end
        end
      end

      def long_fulls
        @sexp.nil? and puff
        if @sexp
          ::Enumerator.new do |y|
            @sexp.children( :long_sexp ).each do |sx|
              y << ( sx.last.values * EMPTY_SEP__ )
            end
            nil
          end
        end
      end

    private

      def puff  # @args -> @norm_short_str @long_sexp @sexp
        sexp = Headless::Library_::CodeMolester::Sexp[ :opt ]
        h = { }
        add = -> k, v do
          ( h[ k ] ||= [ ] ) << sexp.length
          sexp << [ k, v ]
        end
        @args.each do |x|
          if x.respond_to? :ascii_only?
            if Option::Constants::SIMPLE_SHORT_RX =~ x
              add[ :short_full, x ]
            elsif Option::Constants::LONG_RX =~ x
              add[ :long_sexp, Option::Long_.lease_from_matchdata( $~ ) ]
            else
              add[ :desc, x ]
            end
          else
            add[ :other, x ]
          end
        end
        @norm_short_str, @long_sexp = [ :short_full, :long_sexp ].map do |i|
          if h[ i ] && 1 == h.fetch( i ).length
          then sexp.fetch( h.fetch( i ).fetch( 0 ) ).fetch( 1 )
          else false
          end
        end
        @sexp = sexp
        nil
      end
      EMPTY_SEP__ = EMPTY_STRING_
    end

    class Semi_Mutable_ < Model_

      class << self
        public :new
      end

      def initialize norm_long_str
        @desc_a = @long_sexp = nil
        @norm_long_str = norm_long_str
      end

      def append_arg s
        @long_sexp = nil
        @norm_long_str.concat s  # yikes
        nil
      end

      def set_norm_short_str x
        @norm_short_str = x
        nil
      end

      def set_single_letter s
        @norm_short_str = "-#{ s }"
        nil
      end

      def set_desc_a x
        @desc_a = x
        nil
      end

      attr_reader :desc_a

      def single_letter_i
        @norm_short_str[ 1 ].intern
      end

      def to_a
        a = [ ]
        (( s = @norm_short_str )) and a << s
        (( s = @norm_long_str )) and a << s
        @desc_a and a.concat @desc_a
        a
      end
    end
  end
end
