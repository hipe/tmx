module Skylab::Parse

  # ->

    class Functions_::Non_Negative_Integer < Parse_::Function_::Field

      # this function :+#cannot-operate-on-the-empty-stream.

      _RX = /\A\d+\z/

      same_method = -> in_st do
        if _RX =~ in_st.current_token_object.value_x
          tok_o = in_st.current_token_object
          in_st.advance_one
          Parse_::Output_Node_.new tok_o.value_x.to_i
        end
      end

      define_method :output_node_via_input_stream, same_method

      define_singleton_method :output_node_via_input_stream, same_method

    end
    # <-
end
