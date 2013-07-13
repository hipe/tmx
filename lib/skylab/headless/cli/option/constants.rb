module Skylab::Headless

  module CLI::Option

    o = MetaHell::Formal::Box::Open.new

    o[:opt_rx] = /\A-/

    o[:simple_short_rx] = /\A-[^-]/

    o[:short_rx] =  /\A
      -  (?<short_stem> [^-\[= ] )
         (?<short_rest> [-\[= ].* )?
    \z/x

    o[:long_rx] = /\A
      -- (?<no_part> \[no-\] )?
         (?<long_stem> [^\[\]=\s]{2,} )
         (?<long_rest> .+ )?
    \z/x   # names pursuant to `replace_with_long_rx_matchdata`

    CONSTANTS = o.to_struct

  end
end
