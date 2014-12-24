module Skylab::Headless

  module CLI::Option__

    class << self

      def aggregation
        Option_::Aggregation__
      end

      def basic_switch_index_curry switch_s
        Option_::Basic__::Switch_index_curry[ switch_s ]
      end

      def build_via_switch sw
        Option_::Model__.build_via_switch sw
      end

      def enumerator x
        scan( x ).each
      end

      def local_normal_name_as_long i
        Local_normal_name_as_long__[ i ]
      end

      def long_rx
        LONG_RX__
      end

      def merger
        Option_::Merger__
      end

      def model
        Option_::Model__
      end

      def on *a, &p
        const_get( :Model__, false ).on( *a, &p )
      end

      def new_flyweight
        const_get( :Model__, false ).new_flyweight
      end

      def normize stem_s
        Normize__[ stem_s ]
      end

      def opt_rx
        OPT_RX__
      end

      def parser
        Option_::Parser__
      end

      def scan x
        Option_::Scan__[ x ]
      end

      def simple_short_rx
        SIMPLE_SHORT_RX__
      end

      def starts_with_dash * a
        if a.length.zero?
          Starts_with_dash__
        else
          Starts_with_dash__[ * a ]
        end
      end

      def values_at * i_a
        o = @value_struct
        i_a.map do |i|
          o[ i ]
        end
      end
    end

    Local_normal_name_as_long__ = -> i do
      "--#{ i.id2name.gsub UNDERSCORE_, DASH_ }"
    end

    Normize__ = -> s do  # :+[#081]
      s.gsub( DASH_, UNDERSCORE_ ).downcase.intern
    end

    LONG_RX__ = /\A
      -- (?<no_part> \[no-\] )?
         (?<long_stem> [^\[\]=\s]{2,} )
         (?<long_rest> .+ )?
    \z/x   # names pursuant to `replace_with_long_rx_matchdata`

    Option_ = self

    OPT_RX__ = /\A-/

    SHORT_RX__ =  /\A
      -  (?<short_stem> [^-\[= ] )
         (?<short_rest> [-\[= ].* )?
    \z/x

    SIMPLE_SHORT_RX__ = /\A-[^-]/

    Starts_with_dash__ = -> s do
      DASH_BYTE_ == s.getbyte( 0 )
    end

    @value_struct = -> do  # :+[#165]
      i_a = [] ; i_a_ = []
      o = -> i, i_ do
        i_a.push i ; i_a_.push i_ ; nil
      end
      o.singleton_class.send :alias_method, :[]=, :call

      o[ :long_rx ] = LONG_RX__

      o[ :short_rx ] = SHORT_RX__

      ::Struct.new( * i_a ).new( * i_a_ )
    end.call

    # `basic_switch_index_curry` is a hack to see if a basic switch is present
    #
    #     p = Subject_[].basic_switch_index_curry '--foom'
    #     p[ [ 'abc' ] ]  # => nil
    #     p[ [ 'abc', '--fo', 'def' ] ]  # => 1
    #     p[ [ '--foomer', '-fap', '-f', '--foom' ] ]  # => 2


  end
end
