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
    # error is raised by default.
    #
    # (as such, `args` of length zero always succeeds. `args` of length longer
    # than length of `p_a` will always execute the "exhaustion action")
    #
    # NOTE that despite the flexibility that is afforded by such a signature,
    # the position of the actual arguments still is not freeform - they must
    # occur in the same order with respect to each other as they occur in the
    # formal arguments. such a grammar would be possible but is beyond this
    # scope (and is addressed by the sibling nodes of this node).
    #
    # in contrast to the similar-acting `parse_from_ordered_set`, this only
    # matches input that occurs in the same order as the grammar; i.e there
    # is one cursor that tracks the current head of the input, and one cursor
    # that tracks the current head of the grammar. neither cursor ever moves
    # backwards.
    #
    # one-shot, inline usage:
    #
    #     args = [ '30', 'other' ]
    #     age, sex, loc =  MetaHell::FUN.parse_series[ args,
    #       -> a { /\A\d+\z/ =~ a },
    #       -> s { /\A[mf]\z/i =~ s },
    #       -> l { /./ =~ l } ]
    #
    #     age  # => "30"
    #     sex  # => nil
    #     loc  # => 'other'
    #
    # (see what happens when we limit ourselves to binary gender)

    # `curry` can make your code more readable and may improve performance:
    # with `curry` you can separate the step of creating the parser from
    # the step of using it.
    #
    # curry a parser by telling it what part(s) you are giving it,
    # e.g curry this parser by giving it `matchers` in advance of usage:
    #
    #     P = MetaHell::FUN.parse_series.curry[
    #       :token_matchers, [
    #         -> age do
    #           /\A\d+\z/ =~ age
    #         end,
    #         -> sex do
    #           /\A(?:m(?:ale)?|f(?:emale)?|o(?:ther)?)\z/i =~ sex
    #         end,
    #         -> location do
    #           /\A[A-Z]/ =~ location   # must start with capital
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

    o = FUN.redefiner

    o[:parse_series] = FUN.parse_curry[
      :algorithm, -> parse, argv do
        fa = parse.normal_token_proc_a ; fz = fa.length
        ai = fi = 0 ; az = argv.length
        res = ::Array.new fz
        catch :exhausted do
          while ai < az do
            v = argv[ ai ]
            stay = true
            begin
              if fz == fi
                parse.exhaustion_notification argv, ai
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
        raise ::ArgumentError, e.message_proc[]
      end,
      :uncurried_queue, [ :token_matchers, :argv ],
      :call, -> argv, * p_a do
        absorb_along_curry_queue_and_execute p_a, argv
      end
    ]

    # changing it from a matching parser to a scanning parser:
    #
    # way back in ancient times the original inspiration for something like
    # this was writing crazy method signatures, like e.g imagine an abstract
    # representation of a "file" that is constructured with either, both, or
    # none of an ::IO representing the file as a resource on the system, and
    # a ::String representing the file's desired content. it is
    # straightforward enough to accept a glob of arguments to the constructor
    # and programmatically determine which arguments are which, but man alive
    # is it ever ugly looking. the desire of this, then was to allow method
    # signatures to exhibit this flexibility and to yet be readable and
    # concise in both their calls and implementation
    #
    # (this creation myth also suggests why we don't do "pool"-style (non-
    # orderd) parsing - we wanted it to be relatively fast, and also possibly
    # to leverage precedence to avoid grammar ambiguities.)
    #
    # as such, "scanning" (parsing, even (detailed discussion at [#037])) had
    # no real meaning in that context - we were just trying to expand an
    # ordered subset of items to fit within the defined superset, positionally.
    # the actual "identity" of the items stayed the same.
    #
    # any who dad doo, the point of all this is that although it doesn't
    # out of the box treat your functions as scanners, you may find yourself
    # wishing that it did, and that you could easily take care of semantic
    # representation in addition to parsing (again see [#037]).
    #
    # note that while we keep the method signatures simple (monadic in/out),
    # one way to do scanning in addition to matching is to
    # indicate `token_scanners` instead of `token_matchers`:
    #
    #     P = MetaHell::FUN.parse_series.curry[
    #       :token_scanners, [
    #         -> feet   { /\A\d+\z/ =~ feet and feet.to_i },
    #         -> inches { /\A\d+(?:\.\d+)?\z/ =~ inches and inches.to_f }
    #       ] ]
    #
    #     P[ [ "8"   ] ]         # => [ 8,  nil  ]
    #     P[ [ "8.1" ] ]         # => [ nil, 8.1 ]
    #     P[ [ "8", "9" ] ]      # => [ 8, 9.0 ]
    #     P[ [ "8.1", "8.2" ] ]  # => ArgumentError: unrecognized argument ..
    #
    # NOTE however that when doing this you have to be more careful:
    # no longer is the simple true-ishness of your result used to determine
    # whether there was a match. instead, `nil?` is used.

  end
end
