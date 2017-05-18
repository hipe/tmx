module Skylab::Parse

  # ->

    class Functions_::Any_Token < Home_::Function_::Field

      # this function is :+#empty-stream-safe

      def output_node_via_input_stream in_st

        if in_st.unparsed_exists
          Home_::OutputNode.for in_st.gets_one.value
        end
      end

      def moniker
        super or Default_moniker__[]
      end

      Default_moniker__ = Common_.memoize do
        Common_::Name.via_variegated_symbol :any_token
      end
    end
    # <-
end
