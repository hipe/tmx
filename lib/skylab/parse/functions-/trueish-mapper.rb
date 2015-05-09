module Skylab::Parse

  # ->

    class Functions_::Trueish_Mapper < Parse_::Function_::Field::Proc_Based

      # pass to the user proc the input stream. if the result is true-ish,
      # assume this is a mixed output value and that the use proc advanced
      # the input scanner.
      #
      # it is not possible under this function for the user function to
      # produce a false-ish output value.
      #
      # :+#empty-stream-behavior-is-determined-by-user.

      def output_node_via_input_stream in_st
        x = @p[ in_st ]
        if x
          Parse_::Output_Node_.new x
        end
      end
    end
    # <-
end
