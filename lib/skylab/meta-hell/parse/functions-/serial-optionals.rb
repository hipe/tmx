module Skylab::MetaHell

  module Parse  # see [#029]

    # a "serial optionals" parse function never fails. any input stream is
    # passed to the first constituent. if this parse succeeds, any remaining
    # input stream is passed to any next constituent and so on. if the current
    # constituent fails to parse, this constituent is permanently passed over
    # and any remaining constituents are still considered and so on.
    #
    # internally this function is not concerned with whether at the end of
    # the parse there still remain any unparsed tokens in the input buffer.
    #
    # in the output node the result value is always a tuple (array) with its
    # number of elements corresponding to the number of constituents in the
    # grammar. a constituent whose parse succeeded will have its output value
    # (not node) in the position of this output array that corresponds to the
    # constituent's position in the grammar. in those "slots" in the output
    # array where the corresponding constituent failed to parse (or was never
    # reached) the value will be `nil`.
    #
    # this function does not have a sense for the input ending "prematurely".
    # if the end of the input is reached before the end of the grammar, the
    # function simply results with the result value array as-is.
    #
    # this function is :+#empty-stream-safe.
    #
    # there is a highlevel shorthand inline convenience macro:
    #
    #     args = [ '30', 'other' ]
    #     age, sex, loc =  Parse_lib_[].parse_serial_optionals args,
    #       -> a { /\A\d+\z/ =~ a },
    #       -> s { /\A[mf]\z/i =~ s },
    #       -> l { /./ =~ l }
    #
    #     age  # => '30'
    #     sex  # => nil
    #     loc  # => 'other'
    #
    # (see what happens when we limit ourselves to binary gender)

    # currying can make your code more readable and may improve performance:
    # with `curry_with` you can separate the step of creating the parseer
    # from the step of using it.
    #
    # curried usage:
    #
    #     P = Subject_[].new_with(
    #       :matcher_functions,
    #         -> age do
    #           /\A\d+\z/ =~ age
    #         end,
    #         -> sex do
    #           /\A(?:m(?:ale)?|f(?:emale)?|o(?:ther)?)\z/i =~ sex
    #         end,
    #         -> location do
    #           /\A[A-Z]/ =~ location   # must start with capital
    #         end ).to_parse_array_fully_proc
    #
    #
    # full normal case (works to match each of the three terms).
    #
    #     P[ [ '30', 'male', "Mom's basement" ] ]  # => [ '30', 'male', "Mom's basement" ]
    #
    #
    # one valid input token will match any first matching formal symbol found
    #
    #     P[ [ '30' ] ]              # => [ '30', nil, nil ]
    #
    #
    # successful result is always array as long as number of formal symbols
    #
    #     P[ [ "Mom's basement" ] ]  # => [ nil, nil, "Mom's basement" ]
    #
    #
    # ergo an earlier matching formal symbol will always win over a later one
    #
    #     P[ [ 'M' ] ]               # => [ nil, 'M', nil ]
    #
    #
    # because we have that 'fully' suffix, we raise argument errors
    #
    #     argv = [ '30', 'm', "Mom's", "Mom's again" ]
    #     P[ argv ]  # => ArgumentError: unrecognized argument 'Mom's..

    class Functions_::Serial_Optionals < Parse::Function_::Currying

      class << self

        def parse_via_highlevel_arglist a

          # super oldschool highlevel macro: first arg is ARGV, remaining
          # args are matchers (constituency of the grammar). if unparsed
          # exists raise argument error. otherwise result is output tuple.

          arg_st = Callback_::Iambic_Stream.via_array a
          input_array = arg_st.gets_one

          new_with(
            :function_objects_array, Callback_.stream do
              if arg_st.unparsed_exists
                Functions_::Simple_Matcher.new_via_proc arg_st.gets_one
              end
            end.to_a ).to_parse_array_fully_proc[ input_array ]
        end
      end

      def accept_function_ f
        maybe_send_sibling_sandbox_to_function_ f
        super
      end

      def parse_

        formal_d = 0
        is_exhausted = false

        f_p_a = @function_a
        formal_length = f_p_a.length
        output_a = ::Array.new formal_length

        st = @input_stream

        while st.unparsed_exists

          do_stay = true
          begin

            if formal_length == formal_d
              # (exhaustion_notification)
              is_exhausted = true
              break
            end

            on = f_p_a.fetch( formal_d ).output_node_via_input_stream st

            if on
              output_a[ formal_d ] = on.value_x
              do_stay = false
            end

            formal_d += 1

          end while do_stay

          if is_exhausted
            break
          end
        end

        Parse_::Output_Node_.new output_a
      end
    end

    # you can provide arbitrary procs to implement your parse functions
    #
    #     feet_rx = /\A\d+\z/
    #     inch_rx = /\A\d+(?:\.\d+)?\z/
    #
    #     p = Subject_[].new_with(
    #       :functions,
    #       :proc, -> st do
    #         if feet_rx =~ st.current_token_object.value_x
    #           tok = st.current_token_object
    #           st.advance_one
    #           Parse_lib_[]::Output_Node_.new tok.value_x.to_i
    #         end
    #       end,
    #       :proc, -> st do
    #         if inch_rx =~ st.current_token_object.value_x
    #           tok = st.current_token_object
    #           st.advance_one
    #           Parse_lib_[]::Output_Node_.new tok.value_x.to_f
    #         end
    #       end ).to_parse_array_fully_proc
    #
    #     p[ [ "8"   ] ]         # => [ 8,  nil  ]
    #     p[ [ "8.1" ] ]         # => [ nil, 8.1 ]
    #     p[ [ "8", "9" ] ]      # => [ 8, 9.0 ]
    #     p[ [ "8.1", "8.2" ] ]  # => ArgumentError: unrecognized argument ..
    #
    # NOTE however that when doing this you have to be more careful:
    # no longer is the simple true-ishness of your result used to determine
    # whether there was a match. instead, `nil?` is used.

  end
end
