module Skylab::MetaHell

  o = { }

  o[:hash2instance] = -> h do  # (this is here for symmetry with the below
    MetaHell::Proxy::Ad_Hoc[ h ]  # but it somewhat breaks the spirit of FUN)
  end                          # although have a look it's quite simple

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

  # `parse` - For a formal parameter syntax that is made up of one or more
  # contiguous optional arguments, and we want to determine which actual
  # parameters correspond to which formal parameters not in the usual ruby
  # left-to-right way, but via functions, one function per formal argument
  # (imagine a syntax `[age] [sex] [location]` with its seven possible
  # signatures); parse actual args `args` using functions in hash `h`
  # in order `op_a`. Result is always an array of same length as `op_a`
  # with each element either nil or the positionally corresponding actual
  # argument. if an argument cannot be processed with the simple state
  # machine that is created by `h` and `op_a` an argument error will be raised.
  # `args` of length zero always succeeds. `args` of length longer
  # than length of `op_a` will always raise an argument error.
  # Note that despite the flexibility that is afforded by such a signature
  # the position of the actual arguments still is not freeform - they must
  # occur in the same order with respect to each other as they occur
  # in the formal arguments.

  o[:parse] = -> h, args, *op_a do
    # a = actual  f = formal  i = index  z = length
    ai = fi = 0 ; az = args.length ; fz = op_a.length
    res = ::Array.new fz

    while ai < az
      v = args[ai]
      stay = true
      begin
        if fi == fz
          raise ::ArgumentError, "unrecognized argument at index #{ ai } - #{
            }#{ v.inspect }"
        end
        if h[ op_a[fi] ][ v ]
          res[fi] = v
          stay = false
        end
        fi += 1
      end while stay
      ai += 1
    end
    res
  end

  FUN = o[:hash2struct][ o ]

end
