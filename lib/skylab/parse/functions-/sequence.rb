module Skylab::MetaHell

  module Parse

    class Functions_::Sequence < Parse_::Function_::Currying

      # ([#sl-129] three laws all the way. [#hl-119] name conventions.)

      def parse_

        __prepare

        f_st = Callback_::Polymorphic_Stream.via_array @function_a

        if f_st.unparsed_exists
          f = f_st.current_token
        end

        q = []

        begin

          if f
            on = f.output_node_via_input_stream @input_stream
          else
            x = __flush
            break
          end

          if on
            tn = on.try_next
            if tn
              q.push [ f_st.current_index, tn ]
            end
            @result_x_a[ f_st.current_index ] = on.value_x
            f_st.advance_one
            f = if f_st.unparsed_exists
              f_st.current_token
            end
            redo

          elsif q.length.nonzero?
            f = __step_backwards_for_try_again f_st, q
            redo

          else
            __rewind_because_you_failed
            break
          end

        end while nil
        x
      end

      def __prepare
        @initial_input_stream_index = @input_stream.current_index
        @result_x_a = ::Array.new @function_a.length
        @try_next_queue = nil
        nil
      end

      def __step_backwards_for_try_again f_st, q

        function_index, try_again = q.shift
        q.length.nonzero? and self._RIDE_ME

        f_st.current_index = function_index
        @input_stream.current_index = try_again.input_index_for_try_again

        try_again
      end

      def __rewind_because_you_failed
        if @initial_input_stream_index != @input_stream.current_index
          @input_stream.current_index = @initial_input_stream_index
        end
        nil
      end

      def __flush
        Parse_::Output_Node_.new @result_x_a
      end

      # ~ #hook-ins for adjunct facets

      def constituent_delimiter_pair_for_expression_agent _expag
        nil
      end
    end
  end
end
