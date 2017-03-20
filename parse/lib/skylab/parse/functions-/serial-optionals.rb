module Skylab::Parse

  begin  # :/

    # see [#004]
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
    #     _argv = [ '30', 'brisbane' ]
    #
    #     age, sex, loc =  Home_.parse_serial_optionals _argv,
    #       -> a { /\A\d+\z/ =~ a },
    #       -> s { /\A[mf]\z/i =~ s },
    #       -> l { /./ =~ l }
    #
    #     age  # => '30'
    #     sex  # => nil
    #     loc  # => 'brisbane'
    #
    # because the second argument doesn't match our narrow pattern for sex,
    # but it does match our leient pattern for location, it is parsed as that.

    # currying can make your code more readable and may improve performance:
    # with `curry_with` you can separate the step of creating the parseer
    # from the step of using it.
    #
    # curried usage:
    #
    #     p = Home_.function( :serial_optionals ).with(
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
    # full normal case (works to match each of the three terms).
    #
    #     p[ [ '30', 'male', "Mom's basement" ] ]  # => [ '30', 'male', "Mom's basement" ]
    #
    # one valid input token will match any first matching formal symbol found
    #
    #     p[ [ '30' ] ]              # => [ '30', nil, nil ]
    #
    # successful result is always array as long as number of formal symbols
    #
    #     p[ [ "Mom's basement" ] ]  # => [ nil, nil, "Mom's basement" ]
    #
    # ergo an earlier matching formal symbol will always win over a later one
    #
    #     p[ [ 'M' ] ]               # => [ nil, 'M', nil ]
    #
    # because we have that 'fully' suffix, we raise argument errors
    #
    #     argv = [ '30', 'm', "Mom's", "Mom's again" ]
    #     p[ argv ]  # => ArgumentError: unrecognized argument "Mom's..

    class Functions_::Serial_Optionals < Home_::Function_::Currying

      class << self

        def parse_via_highlevel_arglist a

          # super oldschool highlevel macro: first arg is ARGV, remaining
          # args are matchers (constituency of the grammar). if unparsed
          # exists raise argument error. otherwise result is output tuple.

          scn = Scanner_[ a ]
          input_array = scn.gets_one

          with(
            :function_objects_array, Common_.stream do
              if scn.unparsed_exists
                Functions_::Simple_Matcher.via_proc scn.gets_one
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

        Home_::OutputNode.for output_a
      end

      # #hook-out for adjunct facet: syntax expression

      def constituent_delimiter_pair_for_expression_agent _expag
        %w( [ ] )
      end
    end

    # you can provide arbitrary procs to implement your parse functions
    #
    #     feet_rx = /\A\d+\z/
    #     inch_rx = /\A\d+(?:\.\d+)?\z/
    #
    #     p = Home_.function( :serial_optionals ).with(
    #       :functions,
    #       :proc, -> st do
    #         if feet_rx =~ st.current_token_object.value_x
    #           tok = st.current_token_object
    #           st.advance_one
    #           Home_::OutputNode.for tok.value_x.to_i
    #         end
    #       end,
    #       :proc, -> st do
    #         if inch_rx =~ st.current_token_object.value_x
    #           tok = st.current_token_object
    #           st.advance_one
    #           Home_::OutputNode.for tok.value_x.to_f
    #         end
    #       end ).to_parse_array_fully_proc
    #
    # if it's an integer, it matches the first pattern:
    #
    #     p[ [ "8"   ] ]         # => [ 8,  nil  ]
    #
    # but if it's a float, it matches the second pattern:
    #
    #     p[ [ "8.1" ] ]         # => [ nil, 8.1 ]
    #
    # because of positionality, even though the second term is an interger,
    # it still falls into the float "slot":
    #
    #     p[ [ "8", "9" ] ]      # => [ 8, 9.0 ]
    #
    # but the converse is not true; i.e you can't have two floats:
    #
    #     p[ [ "8.1", "8.2" ] ]  # => ArgumentError: unrecognized argument ..
    #
    # NOTE however that when doing this you have to be more careful:
    # no longer is the simple true-ishness of your result used to determine
    # whether there was a match. instead, `nil?` is used.

  end
end
