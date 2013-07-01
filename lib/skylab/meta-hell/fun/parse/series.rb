module Skylab::MetaHell

  module FUN::Parse::Series

    # `parse_series` - parse out (a fixed) N values from M args
    #
    # imagine a formal parameter syntax that is made up of one or more
    # contiguous optional arguments, and we want to determine which actual
    # arguments to tag as which formal arguments not in e.g the usual ruby
    # left-to-right way (if we are talking about a method signature); but
    # rather via functions, one function per formal argument.
    #
    # specifically, consider the example "grammar" of `[age] [sex] [location]`.
    # a primitive attempt at this as a ruby method signature is:
    #
    #   def asl age=nil, sex=nil, location=nil
    #
    # however we would like it to work for calls like
    #
    #   asl "male", "Berlin"
    #
    # which would not work as illustrated. we can, however, create one
    # function for each of the formal parameters that can be used to indicate
    # whether any given actual parameter is a match for the particular
    # formal parameter. we would then be able to accept eight possible
    # permutations of these fields in this order, each one being either
    # provided or not provided; in contrast to the four permutations of
    # pseudo-signatures possible in the ruby example. this facility may
    # offer your application more power without sacrificing clarity or
    # conciseness.
    #
    # the result is always an array of same length as `p_a`, with each element
    # either nil or the positionally corresponding actual argument. if an
    # argument cannot be processed with this simple state machine an argument
    # error is raised.
    #
    # (as such, `args` of length zero always succeeds. `args` of length longer
    # than length of `p_a` will always execute the stop/fail action.)
    #
    # NOTE that despite the flexibility that is afforded by such a signature,
    # the position of the actual arguments still is not freeform - they must
    # occur in the same order with respect to each other as they occur in the
    # formal arguments. such a grammar would be possible but is beyond this
    # scope (and was subsquently addressed by sibling nodes).
    #
    # in contrast to the similar-acting `parse_from_ordered_set`, this only
    # matches input that occurs in the same order as the grammar; i.e there
    # is one currsor that tracks the current head of the input, and one cursor
    # that tracks the current head of the grammar. neither cursor ever moves
    # backwards.
    #
    # (with lowlevel interface) parse all three things:
    #
    #     P = MetaHell::FUN.parse_series.curry[
    #       :matcher_a, [
    #         -> age do
    #           /\A\d+\z/ =~ age and age.to_i
    #         end,
    #         -> sex do
    #           /\A(?:m(?:ale)?|f(?:emale)?|o(?:ther)?)\z/i =~ sex and sex
    #         end,
    #         -> location do
    #           /\A[A-Z]/ =~ location and location # must start with capital
    #         end
    #     ] ]
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
    # but now here's the rub: if you re-curry the parser (!) and
    # if you set `exhaustion` to `false`, it terminates at first non-parsable:
    #
    #     argv = [ '30', 'm', "Mom's", "Mom's again" ]
    #     omg = P.curry[ :exhaustion, false ]
    #     omg[ argv ]  # => [ '30', 'm', "Mom's" ]
    #     argv  # => [ "Mom's again" ]
    #
    # (for contrast, here's the same thing, but with errors:)
    #
    #     argv = [ '30', 'm', "Mom's", "Mom's again" ]
    #     P[ argv ]  # => ArgumentError: unrecognized argument at index 3..
    #

    o = MetaHell::FUN_.o

    o[:parse_series] = FUN.parse_curry[
      :algorithm, -> parser, argv do
        fa = parser.normal_token_proc_a ; fz = fa.length
        ai = fi = 0 ; az = argv.length
        res = ::Array.new fz
        catch :exhausted do
          while ai < az do
            v = argv[ ai ]
            stay = true
            begin
              if fz == fi
                parser.exhaustion_notification argv, ai
                throw :exhausted
              end
              b, x = fa.fetch( fi ).call v
              if b
                res[ fi ] = x
                stay = false
              end
              fi += 1
            end while stay
            ai += 1
          end
        end
        res
      end,
      :exhaustion, -> e do
        raise ::ArgumentError, e.message_function[]
      end,
      :curry_queue, [ :matcher_a, :argv ],
      :call, -> argv, * p_a do
        absorb_along_curry_queue_and_execute p_a, argv
      end
    ]
  end
end
