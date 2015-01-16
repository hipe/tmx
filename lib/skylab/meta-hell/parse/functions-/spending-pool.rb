module Skylab::MetaHell

  module Parse

    # unlike "serial optionals" and "simple pool", this non-terminal function
    # frontiers the use of the new `function_is_spent` field:
    #
    # like "orderd pool" the constituent functions are held in a diminishing
    # pool. unlike "simple pool", these functions are not each necessarily
    # removed from the pool when they succeed in parsing. that is what the
    # `function_is_spent` field is for: IFF the function expresses this field
    # as true-ish (or it fails to match) will it be removed from the pool.
    #
    # this mechanism is crucial for certain kinds of nonterminal functions,
    # those with "trailing optional" kleene-star style constituents.
    #
    # the parse is finished when either no node parsed during that pass
    # or all nodes are spent (that is, when the pool is empty).
    #
    # this function is :+#empty-stream-safe.
    #
    # with one such parser build from an empty set of parsers,
    #
    #     None = Subject_[].via_set.curry_with :pool_procs, []
    #
    #
    # a parser with no nodes in it will always report 'no parse' and 'spent':
    #
    #     None[ argv = [] ]  # => [ false, true ]
    #     argv # => []
    #
    #
    # even if the input is rando calrissian:
    #
    #     None[ argv = :hi_mom ]  # => [ false, true ]
    #     argv  # => :hi_mom


    # with parser with one node that reports it always matches & always spends
    #
    #     One = Subject_[].via_set.curry_with( :pool_procs, [
    #      -> _input {  [ true, true ] }
    #     ] )
    #
    #
    # it always reports the same as a final result:
    #
    #     One[ :whatever ]  # => [ true, true ]


    # with a parser with one node that reports it never matches & always spends
    #
    #     Spendless = Subject_[].via_set.curry_with( :pool_procs, [
    #       -> _input {  [ false, true ] }
    #     ] )
    #
    #
    # it always reports the same as a final result:
    #
    #     Spendless[ :whatever ]  # => [ false, true ]


    # a parser that parses any digits & any of 2 keywords (only once each):
    #
    #     keyword = -> kw do
    #       -> memo, argv do
    #         if argv.length.nonzero? and kw == argv.first
    #           argv.shift
    #           memo[ kw.intern ] = true
    #           [ true, true ]
    #         end
    #       end
    #     end
    #
    #     Digits = Subject_[].via_set.curry_with :pool_procs, [
    #       keyword[ 'foo' ],
    #       keyword[ 'bar' ],
    #       -> memo, argv do
    #         if argv.length.nonzero? and /\A\d+\z/ =~ argv.first
    #           ( memo[:nums] ||= [ ] ) << argv.shift.to_i
    #           [ true, false ]
    #         end
    #       end
    #     ]
    #
    #
    # does nothing with nothing:
    #
    #     Digits[ ( memo = {} ), [] ]  # => [ false, false ]
    #     memo.length  # => 0
    #
    #
    # parses one digit:
    #
    #     Digits[ ( memo = { } ), argv = [ '1' ] ]  # => [ true, false ]
    #     argv.length  # => 0
    #     memo[ :nums ]  # => [ 1 ]
    #
    #
    # parses two digits:
    #
    #     Digits[ ( memo = { } ), argv = [ '2', '3' ] ]  # => [ true, false ]
    #     argv.length  # => 0
    #     memo[ :nums ]  # => [ 2, 3 ]
    #
    #
    # parses one keyword:
    #
    #     Digits[ ( memo = { } ), argv = [ 'bar' ] ]  # => [ true, false ]
    #     argv.length  # => 0
    #     memo[ :bar ]  # => true
    #
    #
    # parses two keywords:
    #
    #     Digits[ ( memo = { } ), argv = [ 'bar', 'foo' ] ]  # => [ true, false ]
    #     argv.length  # => 0
    #     memo[ :bar ]  # => true
    #     memo[ :foo ]  # => true
    #
    #
    # will not parse multiple of same keyword:
    #
    #     Digits[ ( memo = { } ), argv = [ 'foo', 'foo' ] ]  # => [ true, false ]
    #     argv  # => [ 'foo' ]
    #     memo[ :foo ]  # => true
    #
    #
    # will stop at first non-parsable:
    #
    #     argv = [ '1', 'foo', '2', 'biz', 'bar' ]
    #     Digits[ ( memo = { } ), argv ]  # => [ true, false ]
    #     argv  # => [ 'biz', 'bar' ]
    #     memo[ :nums ]  # => [ 1, 2 ]
    #     memo[ :foo  ]  # => true
    #     memo[ :bar  ]  # => nil


    class Functions_::Spending_Pool < Parse_::Function_::Currying

      def parse_

        func_a = @function_a
        d = func_a.length
        res_a = ::Array.new d
        pool_idx_a = d.times.to_a
        d = nil

        in_st = @input_stream

        did_parse_any = did_spend_all = parsed_none_last_pass = false

        unparsed_exists = in_st.unparsed_exists

        while unparsed_exists

          pool_length = pool_idx_a.length

          if pool_length.zero?
            did_spend_all = true
            break
          end

          if parsed_none_last_pass
            break
          end

          spent_this_pass = parsed_this_pass = false

          pool_length.times do | idx_idx |

            func_idx = pool_idx_a.fetch idx_idx

            on = func_a.fetch( func_idx ).output_node_via_input_stream in_st

            if on

              ( res_a[ func_idx ] ||= [] ).push on.value_x

              parsed_this_pass = true
              is_spent = on.function_is_spent
              unparsed_exists = in_st.unparsed_exists

            else
              is_spent = false
                # hm .. did the function "spend" even though it didn't parse?
            end

            if is_spent
              spent_this_pass = true
              pool_idx_a[ idx_idx ] = nil
            end

            unparsed_exists or break
          end

          if spent_this_pass
            pool_idx_a.compact!
          end

          if parsed_this_pass
            did_parse_any = true
          else
            parsed_none_last_pass = true
          end
        end

        if did_parse_any

          Parse_::Output_Node_.new_with res_a, :did_spend_function, did_spend_all

        end
      end
    end
  end
end
