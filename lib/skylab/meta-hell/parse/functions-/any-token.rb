module Skylab::MetaHell

  module Parse

    class Functions_::Any_Token < Parse::Function_::Field

      # this function is :+#empty-stream-safe

      def output_node_via_input_stream in_st

        if in_st.unparsed_exists
          Parse_::Output_Node_.new in_st.gets_one.value_x
        end
      end
    end
  end
end
