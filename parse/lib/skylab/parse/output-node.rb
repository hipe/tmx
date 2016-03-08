module Skylab::Parse

  # ->

    class OutputNode

      Callback_::Actor.methodic self, :properties, :try_next

      class << self
        def new_with * x_a
          ok = nil
          x = new do
            ok = __init_with_magic_syntax_via_polymorphic_stream(
              polymorphic_stream_via_iambic x_a )
          end
          ok && x
        end

        attr_reader :the_empty_node
      end

      def initialize * a, & edit_p  # value | block
        if a.length.zero?
          instance_exec( & edit_p )  # comport to [cb] actor
        else
          @function_is_spent = true
          @value_x = a.fetch( a.length - 1 << 2 )
        end
      end

      @the_empty_node = new( nil ).freeze

      def members
        [ :constituent_index, :function_is_spent, :try_next, :value_x ]
      end

      attr_reader :constituent_index, :function_is_spent, :try_next, :value_x

      def new_with * x_a
        otr = dup
        ok = nil
        otr.instance_exec do
          ok = process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
        end
        ok && otr
      end

    private

      def __init_with_magic_syntax_via_polymorphic_stream st
        @value_x = st.gets_one
        process_polymorphic_stream_fully st
      end

      def constituent_index=
        @constituent_index = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def did_spend_function=
        @function_is_spent = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def function_is_not_spent=
        @function_is_spent = false
        KEEP_PARSING_
      end

    public

      def mutate_try_next_ x
        @try_next = x ; nil
      end

      attr_reader(
        :constituent_index,
        :function_is_spent,
        :try_next,
        :value_x,
      )
    # -
  end
end
