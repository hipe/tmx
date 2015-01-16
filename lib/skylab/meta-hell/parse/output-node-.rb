module Skylab::MetaHell

  module Parse

    class Output_Node_

      Callback_::Actor.methodic self

      class << self
        def new_with * x_a
          ok = nil
          x = new do
            ok = __init_with_magic_syntax_via_iambic_stream(
              iambic_stream_via_iambic_array x_a )
          end
          ok && x
        end
      end

      def initialize * a, & edit_p
        if 1 == a.length
          @function_is_spent = true
          @value_x = a.first
        else
          instance_exec( & edit_p )
        end
      end

      def members
        [ :function_is_spent, :value_x ]
      end

      attr_reader :function_is_spent, :value_x

      def new_with * x_a
        otr = dup
        ok = nil
        otr.instance_exec do
          ok = process_iambic_stream_fully iambic_stream_via_iambic_array x_a
        end
        ok && otr
      end

    private

      def __init_with_magic_syntax_via_iambic_stream st
        @value_x = st.gets_one
        process_iambic_stream_fully st
      end

      def did_spend_function=
        @function_is_spent = iambic_property
        KEEP_PARSING_
      end

      def function_is_not_spent=
        @function_is_spent = false
        KEEP_PARSING_
      end
    end
  end
end
