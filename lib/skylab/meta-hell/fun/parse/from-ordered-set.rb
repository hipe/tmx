module Skylab::MetaHell

  class FUN_

    # `parse_from_ordered_set` result is array of same length as `set_a`.
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
    #     PARSER = MetaHell::FUN.parse_from_ordered_set.curry[ [
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

    o[:parse_from_ordered_set] = -> set_a, argv do
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

    module Parse
      From_Ordered_Set = nil  # #a-load-handle-for-doc-test
    end
  end
end
