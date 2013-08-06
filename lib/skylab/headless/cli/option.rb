module Skylab::Headless

  module CLI::Option

    Option = self

    def self.on *a, &b
      const_get( :Model_, false ).on( *a, &b )
    end

    def self.new_flyweight
      const_get( :Model_, false ).new_flyweight
    end

    o = { }

    Local_normal_name_as_long = -> i do
      "--#{ i.to_s.gsub '_', '-' }"
    end

    o[:normize] = -> x do  # part of [#hl-081] family
      x.gsub( '-', '_' ).downcase.intern
    end

    o[:starts_with_dash] = -> tok do
      DASH_ == tok.getbyte( 0 )
    end

    DASH_ = MetaHell::DASH_

    FUN, FUN_ = MetaHell::FUN.autoloadize_fun[ o ]

    MetaHell::MAARS::Upwards[ FUN ]

    x = FUN_.x

    x[:basic_switch_index_curry] = [ :Basic_ ]

  end
end
