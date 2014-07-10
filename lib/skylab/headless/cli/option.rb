module Skylab::Headless

  module CLI::Option

    Option = self

    def self.on *a, &b
      const_get( :Model_, false ).on( *a, &b )
    end

    def self.new_flyweight
      const_get( :Model_, false ).new_flyweight
    end

    FUN = Headless::Library_::FUN_Module.new

    Autoloader_[ FUN ]  # we need to a.l children

    o = FUN.send :definer

    Local_normal_name_as_long = -> i do
      "--#{ i.to_s.gsub '_', '-' }"
    end

    o[:normize] = -> x do  # part of [#081] family
      x.gsub( '-', '_' ).downcase.intern
    end

    o[:starts_with_dash] = -> tok do
      DASH_ == tok.getbyte( 0 )
    end

    x = FUN.send :predefiner

    # hack to see if a basic switch is present
    # like this
    #
    #     P = Headless::CLI::Option::FUN.basic_switch_index_curry[ '--foom' ]
    #     P[ [ 'abc' ] ]  # => nil
    #     P[ [ 'abc', '--fo', 'def' ] ]  # => 1
    #     P[ [ '--foomer', '-fap', '-f', '--foom' ] ]  # => 2

    x[:basic_switch_index_curry] = [ :Basic_ ]


    class Constants_Module__ < ::Module
      def values_at * i_a
        i_a.map { |i| const_get i, false }
      end
    end

    Constants = Constants_Module__.new

    module Constants

      OPT_RX = /\A-/

      SIMPLE_SHORT_RX = /\A-[^-]/

      SHORT_RX =  /\A
        -  (?<short_stem> [^-\[= ] )
           (?<short_rest> [-\[= ].* )?
      \z/x

      LONG_RX = /\A
        -- (?<no_part> \[no-\] )?
           (?<long_stem> [^\[\]=\s]{2,} )
           (?<long_rest> .+ )?
      \z/x   # names pursuant to `replace_with_long_rx_matchdata`

    end
  end
end
