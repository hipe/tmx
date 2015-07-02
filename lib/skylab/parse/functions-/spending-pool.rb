module Skylab::Parse

  # ->

    # unlike "serial optionals" and "simple pool", this non-terminal function
    # frontiers the use of the new `function_is_spent` field:
    #
    # like "orderd pool" the constituent functions are held in a diminishing
    # pool. unlike "simple pool", these functions are not each necessarily
    # removed from the pool when they succeed in parsing. that is what the
    # `function_is_spent` field is for: IFF the function expresses this field
    # as true-ish (or it fails to match) will it be removed from the pool.
    #
    # this mechanism is an experiment to explore certain kinds of nonterminal
    # functions, those with "trailing optional" kleene-star style constituents.
    #
    # the parse is finished when either no node parsed during that pass
    # or all nodes are spent (that is, when the pool is empty).
    #
    # this function is :+#empty-stream-safe.
    #
    # with one such parser build from an empty set of parsers,
    #
    #     None = Subject_[].new_with( :functions ).to_output_node_and_mutate_array_proc
    #
    #
    # a parser with no nodes in it will always report 'no parse' and 'spent':
    #
    #     None[ EMPTY_A_ ]  # => nil
    #
    #
    # even if the input is rando calrissian:
    #
    #     None[ :hi_mom ]  # => nil


    # with parser with one node that reports it always matches & always spends
    #
    #     One = Subject_[].new_with(
    #       :functions,
    #         :proc, -> in_st do
    #           Parse_lib_[]::Output_Node_.new nil
    #         end ).to_output_node_and_mutate_array_proc
    #
    # is always the same output node:
    #
    #     on = One[ :whatever ]
    #     on.function_is_spent  # => true


    # with a parser with one node that reports it never matches & always spends
    #
    #     Spendless = Subject_[].new_with(
    #       :functions,
    #         :proc, -> in_st do
    #           nil
    #         end ).to_output_node_and_mutate_array_proc
    #
    # it never parses:
    #
    #     Spendless[ :whatever ]  # => nil


    # of 2 keywords, parse them at most once each. parse any and all digits:
    #
    #     _NNI = Parse_lib_[]::Functions_::Non_Negative_Integer
    #
    #     Digits = Subject_[].new_with(
    #       :functions,
    #         :keyword, "foo",
    #         :keyword, "bar",
    #         :proc, -> in_st do
    #           on = _NNI.output_node_via_input_stream in_st
    #           if on
    #             on.new_with :function_is_not_spent
    #           end
    #         end ).to_output_node_and_mutate_array_proc
    #
    #
    # does nothing with nothing:
    #
    #     Digits[ EMPTY_A_ ]  # => nil
    #
    #
    # parses one digit:
    #
    #     argv = [ '1' ]
    #     on = Digits[ argv ]
    #     argv.length  # => 0
    #     on.function_is_spent  # => false
    #     kw, k2, digits = on.value_x
    #     ( kw || k2 )  # => nil
    #     digits  # => [ 1 ]
    #
    #
    # parses two digits:
    #
    #     argv = %w( 2 3 )
    #     on = Digits[ argv ]
    #     on.function_is_spent  # => false
    #     on.value_x  # => [ nil, nil, [ 2, 3 ] ]
    #
    #
    # parses one keyword:
    #
    #     argv = [ 'bar' ]
    #     on = Digits[ argv ]
    #     on.function_is_spent  # => false
    #     on.value_x  # => [ nil, [:bar], nil ]
    #
    #
    # parses two keywords (in reverse grammar order):
    #
    #     argv = %w( bar foo )
    #     on = Digits[ argv ]
    #     argv.length  # => 0
    #     on.function_is_spent  # => false
    #     on.value_x  # => [ [:foo], [:bar], nil ]
    #
    #
    # will not parse multiple of same keyword:
    #
    #     argv = %w( foo foo )
    #     on = Digits[ argv ]
    #     argv  # => %w( foo )
    #     on.function_is_spent  # => false
    #     on.value_x  # => [ [ :foo ], nil, nil ]
    #
    #
    # will stop at first non-parsable:
    #
    #     argv = [ '1', 'foo', '2', 'biz', 'bar' ]
    #     on = Digits[ argv ]
    #     on.function_is_spent  # => false
    #     argv  # => [ 'biz', 'bar' ]
    #     on.value_x  # => [ [ :foo ], nil, [ 1, 2 ] ]


    class Functions_::Spending_Pool < Home_::Function_::Currying

      def accept_function_ f
        maybe_send_sibling_sandbox_to_function_ f
        super
      end

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

          Home_::Output_Node_.new_with res_a, :did_spend_function, did_spend_all

        end
      end
    end
    # <-
end
