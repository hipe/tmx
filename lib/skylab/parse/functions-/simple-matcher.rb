module Skylab::Parse

  # ->

    class Functions_::Simple_Matcher < Parse_::Function_::Field::Proc_Based

      # the user function receives the front token *value* of the input
      # stream. the true-ish-ness of this callback's result signifies
      # whether or not this function considers the input token a "match".
      # if it does, the topic node's result will be an output node whose
      # value is the same as the input token value.
      #
      # the topic node is responsible for advancing the scanner (the user
      # function cannot).
      #
      # this function :+#cannot-operate-on-the-empty-stream

      def output_node_via_input_stream in_st
        if @p[ in_st.current_token_object.value_x ]
          tok = in_st.current_token_object  # change when necessary.
          in_st.advance_one
          tok
        end
      end
    end
    # <-
end
