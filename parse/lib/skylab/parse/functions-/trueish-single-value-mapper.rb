module Skylab::Parse

  # ->

    class Functions_::Trueish_Single_Value_Mapper < Home_::Function_::Field::Proc_Based

      # the user function receives the front token *value* of the input
      # stream. a true-ish result signifies both that this is a "match"
      # and that this value should be used for the output node value. the
      # topic node must advance the scanner (the user function cannot).
      #
      # it is not possible under this function for the user function to
      # produce a false-ish output value.
      #
      # this function :+#cannot-operate-on-the-empty-stream.

      def output_node_via_input_stream in_st
        x = @p[ in_st.current_token_object.value_x ]
        if x
          in_st.advance_one
          Home_::OutputNode.for x
        end
      end
    end
    # <-
end
