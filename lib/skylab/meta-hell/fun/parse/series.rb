module Skylab::MetaHell

  FUN::Parse.const_set :Series, nil  # #loading-handle

  class FUN_

    # `parse_series` - parse out (a fixed) N values from (0..N) args
    #
    # For a formal parameter syntax that is made up of one or
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
    # scope
    #
    # in contrast to the very similar `parse_from_ordered_set`, this one is
    # "anchored" to the search position in the input, so that unrecognized
    # tokens here will trigger a parse failure.
    #
    # (with lowlevel interface) parse all three things:
    #
    #     P_ = MetaHell::FUN._parse_series.curry[
    #       [
    #         -> age do
    #           /\A\d+\z/ =~ age
    #         end,
    #         -> sex do
    #           /\A(?:m(?:ale)?|f(?:emale)?|o(?:ther)?)\z/i =~ sex
    #         end,
    #         -> location do
    #           /\A[A-Z]/ =~ location  # must start with capital
    #         end
    #       ] ]
    #
    #     P = P_.curry[
    #       -> e { raise ::ArgumentError, e.message_function.call }
    #     ]
    #
    #     P[ [ '30', 'male', "Mom's basement" ] ]  # => [ '30', 'male', "Mom's basement" ]
    #
    # or just the first one:
    #
    #     P[ [ '30' ] ]              # => [ '30', nil, nil ]
    #
    # or just the last one:
    #
    #     P[ [ "Mom's basement" ] ]  # => [ nil, nil, "Mom's basement" ]
    #
    # or just the middle one, etc (note it gets precedence over last)
    #
    #     P[ [ 'M' ] ]               # => [ nil, 'M', nil ]
    #
    # but now here's the rub: if you pass `false` for the error handler:
    #
    #     argv = [ '30', 'm', "Mom's", "Mom's again" ]
    #     P_[ false, argv ]  # => [ '30', 'm', "Mom's" ]
    #     argv  # => [ "Mom's again" ]
    #
    # (for contrast, here's the same thing, but with errors:)
    #
    #     argv = [ '30', 'm', "Mom's", "Mom's again" ]
    #     P[ argv ]  # => ArgumentError: unrecognized argument at index 3..
    #

    o[:parse_series] = -> args, *f_a do
      FUN._parse_series[ f_a, -> e do
        raise ::ArgumentError, e.message_function.call
      end, args ]
    end

    Parse_Series_Failure_ = ::Struct.new :message_function, :index, :value

    o[:_parse_series] = -> f_a, err, args do  # #curry-friendly
      # a = actual  f = formal  i = index  z = length
      ai = fi = 0 ; az = args.length ; fz = f_a.length
      res = ::Array.new fz
      while ai < az
        v = args[ai]
        stay = true
        begin
          if fi == fz
            if false == err
              args[ 0, fz ] = MetaHell::EMPTY_A_
            else
              err[ Parse_Series_Failure_[
                -> { "unrecognized argument at index #{ ai } - #{ v.inspect }" },
                ai, v ] ]
            end
            break  # whatever was completed
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
