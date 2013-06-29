module Skylab::MetaHell

  o = { }

  o[:hash2instance] = -> h do  # (this is here for symmetry with the below
    MetaHell::Proxy::Ad_Hoc[ h ]  # but it somewhat breaks the spirit of FUN)
  end                          # although have a look it's quite simple

  o[:hash2struct] = -> h do
    s = ::Struct.new(* h.keys ).new ; h.each { |k, v| s[k] = v } ; s
  end                           # ( for posterity this is left intact but
                                # we do this a simpler way now )

  o[:memoize] = -> func do      # creates a function `func2` from `func`.
    use = -> do                 # the first time `func2` is called, it calls
      x = func.call             # `func` and stores its result in memory,
      use = -> { x }            # and also uses that result as its result.
      x                         # each subsequent time you call `func2` it
    end                         # uses that same result stored in memory from
    -> { use.call }             # the first time you called it. please be
  end                           # careful.

  o[:without_warning] = -> f do
    x = $VERBOSE; $VERBOSE = nil
    r = f.call                   # `ensure` is out of scope for now
    $VERBOSE = x
    r
  end

  o[:require_quietly] = -> s do   # load a library that is not warning friendly
    o[:without_warning][ -> { require s } ]
  end

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
  # scope (see `parse_with_ordered_set`)

  o[:parse_series] = -> args, *f_a do
    o[:_parse_series][ args, f_a, -> e do
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

  # `parse_with_ordered_set` result is array of same length as `set_a`.
  # consider using `curry` on it to create a parser object.
  # sorta like the packrat parser algorithm, `argv` (if any) will be evaluated
  # against each remaining element in `set_a`. each element of `set_a` is
  # assumed to be a function that takes one arg: `argv`. if that function's
  # result is anything other than nil, it is taken to mean it succeeded in
  # matching (and should probably have shifted one or more elements off of
  # `argv`). if the function matched, the function is removed from the
  # running. the parse is finished and the function yields a result when
  # either `argv` is empty or there are no more unmatched elements in `set_a`
  # *or* a matching function could not be found for the current front element
  # of `argv`.  (this function is [#027].)
  # like so:
  #
  #     PARSER = MetaHell::FUN.parse_with_ordered_set.curry[ [
  #       -> args { args.shift if args.first =~ /bill/i },
  #       -> args { if :hi == args.first then args.shift and :hello end } ] ]
  #
  #     1  # => 1
  #
  # result array is in order of "grammar", not of elements in argv:
  #
  #     argv = [ :hi, 'BILLY', 'bob' ]
  #     one, two = PARSER.call argv
  #     one  # => 'BILLY'
  #     two  # => :hello
  #     argv # => [ 'bob' ]
  #
  # it cannot fail (if `set_a` is array of monadic functions and `argv` is ary)
  #
  #     argv = [ :nope ]
  #     res = PARSER.call argv
  #     res  # => [ nil, nil ]
  #     argv # => [ :nope ]
  #
  # an unparsable element will "mask" subsequent would-be parsables:
  #
  #     argv = [ :nope, 'BILLY', :hi ]
  #     res = PARSER.call argv
  #     res  # => [ nil, nil ]
  #     argv.length  # => 3
  #

  o[:parse_with_ordered_set] = -> set_a, argv do
    len = set_a.length
    running_a = len.times.to_a
    res_a = ::Array.new len
    while argv.length.nonzero? and running_a.length.nonzero?
      index, res = running_a.each_with_index.reduce nil do |_, (idx, idx_idx)|
        x = set_a.fetch( idx ).call argv
        if ! x.nil?
          running_a[ idx_idx ] = nil
          running_a.compact!
          break [ idx, x ]
        end
      end
      index or break
      res_a[ index ] = res
    end
    res_a
  end

  # `tuple_tower` - given a stack of functions and one seed value, resolve
  # one result.. fuller description at [#fa-026].
  #
  # opaque but comprehensive example:
  #
  #     f_a = [
  #       -> item do
  #         if 'cilantro' == item                 # the true-ishness of the 1st
  #           [ false, 'i hate cilantro' ]        # element in the result tuple
  #         else                                  # determines short circuit
  #           [ true, item, ( 'red' == item ? 'tomato' : 'potato' ) ]
  #         end                                   # three above becomes two
  #       end, -> item1, item2 do                 # here, b.c the 1st is
  #         if 'carrots' == item1                 # discarded when true
  #           "let's have carrots and #{ item2 }" # note no tuple necessary
  #         elsif 'tomato' == item2               # if it's just one true-ish
  #           [ false, 'nope i hate tomato' ]     # non-true item
  #         else
  #           [ item1, item2 ]
  #         end
  #       end ]
  #     s = MetaHell::FUN.tuple_tower[ 'cilantro',  * f_a ]
  #     s # => 'i hate cilantro'
  #     s = MetaHell::FUN::tuple_tower[ 'carrots', * f_a ]
  #     s # => "let's have carrots and potato"
  #     s = MetaHell::FUN.tuple_tower[ 'red', * f_a ]
  #     s # => 'nope i hate tomato'
  #     x = MetaHell::FUN.tuple_tower[ 'blue', * f_a ]
  #     x # => [ 'blue', 'potato' ]
  #
  # Blue potato. everything should be perfectly clear now.

  o[:tuple_tower] = -> args1, *f_a do
    f_a.reduce args1 do |args, f|
      a = [ * f[ * args ] ]  # normalizes
      tf = a.fetch 0
      if tf
        a.shift if true == tf
        1 == a.length ? a[ 0 ] : a
      else
        a.shift if false == tf
        break( 1 == a.length ? a[ 0 ] : a )
      end
    end
  end

  FUN = o[:hash2struct][ o ]

end
