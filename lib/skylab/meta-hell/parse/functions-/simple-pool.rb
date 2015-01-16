module Skylab::MetaHell

  module Parse

    # :[#027]: this function cannot fail. output value is a tuple (array)
    # whose length is the number of constituents in the grammar.
    #
    # inspired by the packrat parser algorithm. the constituent parse
    # functions of this nonterminal are put in an ordered "pool", in the order
    # they exist in the grammar. the input scanner is passed to each function
    # in this pool in its order. any first function that matches against the
    # scanner will be removed from the pool. (in such cases the function
    # should probably have advanced the scanner).
    #
    # if there is more remaining unparsed input in the scanner and more
    # remaining unused functions in the pool, this process is repeated again
    # from the front item of the pool.
    #
    # the parse is finished when either a) there is nothing more to parse in
    # the input scanner or b) there are no more functions left in the pool or
    # c) a matching function is not found for the current state of the input
    # scanner.
    #
    # in contrast to the similar acting "serial optionals" nonterminal
    # function, this algorithm treats the pool as set - any function in it
    # can match the current state of input; whereas with the other function,
    # the input symbols must occur in the order their corresponding functions
    # appear in the grammar. we call this function "ordered" only because our
    # result structure is a tuple whose items correspond to the grammar
    # constituents positionally.
    #
    # this function is :+#empty-stream-safe.
    #
    # with an ordered set parser (built from a list of arbitrary procs)
    #
    #     PARSER = Subject_[].via_ordered_set.curry_with(
    #       :argv_streams, [
    #         -> args { args.shift if args.first =~ /bill/i },
    #         -> args { if :hi == args.first then args.shift and :hello end } ] )
    #
    #
    # result array is in order of "grammar", not of elements in argv:
    #
    #     argv = [ :hi, 'BILLY', 'bob' ]
    #     one, two = PARSER.call argv
    #     one  # => 'BILLY'
    #     two  # => :hello
    #     argv # => [ 'bob' ]
    #
    #
    # it cannot fail (if `set_a` is array of monadic functions and `argv` is ary)
    #
    #     argv = [ :nope ]
    #     res = PARSER.call argv
    #     res  # => [ nil, nil ]
    #     argv # => [ :nope ]
    #
    #
    # an unparsable element will "mask" subsequent would-be parsables:
    #
    #     argv = [ :nope, 'BILLY', :hi ]
    #     res = PARSER.call argv
    #     res  # => [ nil, nil ]
    #     argv.length  # => 3
    #

    class Functions_::Simple_Pool < Parse::Function_::Currying

      def parse_
        pool_a = @function_a
        len = pool_a.length
        pool_idx_a = len.times.to_a
        res_a = ::Array.new len
        in_st = @input_stream

        while in_st.unparsed_exists && pool_idx_a.length.nonzero?

          index, x = pool_idx_a.each_with_index.reduce nil do |_, (idx, idx_idx)|

            on = pool_a.fetch( idx ).output_node_via_input_stream in_st

            if on
              pool_idx_a[ idx_idx, 1 ] = EMPTY_A_
              break [ idx, on.value_x ]
            end
          end

          if index
            res_a[ index ] = x
          else
            break
          end
        end

        Parse_::Output_Node_.new res_a
      end
    end
  end
end
