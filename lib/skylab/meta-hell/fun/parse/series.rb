module Skylab::MetaHell

  class FUN_

    # `parse_series` - For a formal parameter syntax that is made up of one or
    # more contiguous optional arguments, and we want to determine which actual
    # parameters correspond to which formal parameters not in the usual ruby
    # left-to-right way, but via functions, one function per formal argument
    # (imagine a syntax `[age] [sex] [location]` with its seven possible
    # signatures); parse actual args `args` using the functions in `f_a`.
    #
    # result is always an array of same length as `f_a`, with each element
    # either nil or the positionally corresponding actual argument. if an
    # argument cannot be processed with this simple state machine an argument
    # error is raised.
    #
    # (as such, `args` of length zero always succeeds. `args` of length longer
    # than length of `f_a` will always raise an argument error.)
    #
    # NOTE that despite the flexibility that is afforded by such a signature,
    # the position of the actual arguments still is not freeform - they must
    # occur in the same order with respect to each other as they occur in the
    # formal arguments. such a grammar would be possible but is beyond this
    # scope (see `parse_from_ordered_set`)

    o[:parse_series] = -> args, *f_a do
      FUN._parse_series[ args, f_a, -> e do
        raise ::ArgumentError, e.message_function.call
      end ]
    end

    Parse_Series_Failure_ = ::Struct.new :message_function, :index, :value

    o[:_parse_series] = -> args, f_a, err do
      # a = actual  f = formal  i = index  z = length
      ai = fi = 0 ; az = args.length ; fz = f_a.length
      res = ::Array.new fz
      while ai < az
        v = args[ai]
        stay = true
        begin
          if fi == fz
            err[ Parse_Series_Failure_[
              -> { "unrecognized argument at index #{ ai } - #{ v.inspect }" },
              ai, v ] ]
            break  # sure, let them have whatever was completed.
          end
          if f_a.fetch( fi ).call( v )
            res[fi] = v
            stay = false
          end
          fi += 1
        end while stay
        ai += 1
      end
      res
    end
  end
end
