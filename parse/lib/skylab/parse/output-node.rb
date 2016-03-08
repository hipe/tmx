module Skylab::Parse

  # ->

    class OutputNode

      Attributes_actor_.call( self,
        constituent_index: nil,
        did_spend_function: [ :ivar, :@function_is_spent ],
        try_next: nil,
      )

      # == begin retrofitting for nasty old syntax:
      #    when built with atom, init as atom as we do (A)
      #    when building a new one, do [#ca-057] an "ideal mixed syntax" (B)
      #    when duping & modifying, use plain-old iambic syntax (C)

      class << self

        def for x
          new.__init_for_atom x
        end

        attr_reader :the_empty_node
        private :new
      end  # >>

      def initialize
        # (hi.)
      end

      def __init_for_atom x  # :(A)
        @function_is_spent = true
        @value_x = x
        self
      end

      @the_empty_node = self.for( nil ).freeze

      def new_with * x_a  # :(C)
        o = dup
        _st = polymorphic_stream_via_iambic x_a
        _kp = o.send :___eek_orig_etc, _st
        _kp && o
      end

      alias_method :___eek_orig_etc, :process_polymorphic_stream_passively

      def process_polymorphic_stream_passively st  # :(B)
        # implement a [#ca-057] "ideal mixed syntax"
        @value_x = st.gets_one
        super
      end

      # == end prickly syntax

    private

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
    end
    # <-
end
# #pending-rename: publicize
