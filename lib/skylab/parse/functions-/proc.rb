module Skylab::Parse

  # ->

    class Functions_::Proc < Home_::Function_::Field::Proc_Based

      # :+#empty-stream-behavior-is-determined-by-user.

      def output_node_via_input_stream in_st
        @p[ in_st ]
      end
    end
    # <-
end
