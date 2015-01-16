module Skylab::MetaHell

  module Parse

    class Functions_::Simple_Matcher < Parse_::Function_::Field::Proc_Based

      def output_node_via_input_stream in_st
        if @p[ in_st.current_token_object.value_x ]
          tok = in_st.current_token_object
          in_st.advance_one
          tok
        end
      end
    end
  end
end
