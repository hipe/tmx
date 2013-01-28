module Skylab::MetaHell

  o = { }

  o[:hash2instance] = -> h do
    i = MetaHell::Plastic::Instance.new
    h.each { |k, f| i.define_singleton_method k, &f }
    i
  end

  o[:hash2struct] = -> h do
    s = ::Struct.new(* h.keys ).new ; h.each { |k, v| s[k] = v } ; s
  end

  o[:memoize] = -> func do      # creates a function `func2` from `func`.
    use = -> do                 # the first time `func2` is called, it calls
      x = func.call             # `func` and stores its result in memory,
      use = -> { x }            # and also uses that result as its result.
      x                         # each subsequent time you call `func2` it
    end                         # uses that same result stored in memory from
    -> { use.call }             # the first time you called it. please be
  end                           # careful.

  FUN = o[:hash2struct][ o ]

end
