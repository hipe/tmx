module Skylab::Parse

  # ->

    class Functions_::Any_Token < Parse_::Function_::Field

      # this function is :+#empty-stream-safe

      def output_node_via_input_stream in_st

        if in_st.unparsed_exists
          Parse_::Output_Node_.new in_st.gets_one.value_x
        end
      end

      def moniker
        super or Default_moniker__[]
      end

      Default_moniker__ = Callback_.memoize do
        Callback_::Name.via_variegated_symbol :any_token
      end
    end
    # <-
end
