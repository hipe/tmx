module Skylab::Headless

  module CLI::Option

    Option = self

    def self.on *a, &b
      const_get( :Model_, false ).on( *a, &b )
    end

    def self.new_flyweight
      const_get( :Model_, false ).new_flyweight
    end

    MetaHell::MAARS::Upwards[ FUN = MetaHell::FUN::Module.new ]
    o = FUN.send :definer

    Local_normal_name_as_long = -> i do
      "--#{ i.to_s.gsub '_', '-' }"
    end

    o[:normize] = -> x do  # part of [#hl-081] family
      x.gsub( '-', '_' ).downcase.intern
    end

    o[:starts_with_dash] = -> tok do
      DASH_ == tok.getbyte( 0 )
    end
    #
    DASH_ = MetaHell::DASH_

    x = FUN.send :predefiner

    # hack to see if a basic switch is present
    # like this
    #
    #     P = Headless::CLI::Option::FUN.basic_switch_index_curry[ '--foom' ]
    #     P[ [ 'abc' ] ]  # => nil
    #     P[ [ 'abc', '--fo', 'def' ] ]  # => 1
    #     P[ [ '--foomer', '-fap', '-f', '--foom' ] ]  # => 2

    x[:basic_switch_index_curry] = [ :Basic_ ]


  end
end
