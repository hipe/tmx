module Skylab::Parse

  # ->

    class OutputNode

      Attributes_actor_.call( self,
        constituent_index: nil,
        did_spend_function: [ :ivar, :@function_is_spent ],
        try_next: nil,
      )

      # == begin retrofitting for nasty old syntax:
      #    when built with atom, init as atom as we do #here1
      #    when building a new one, do [#ca-057] an "ideal mixed syntax" #here2
      #    when duping & modifying, use plain-old iambic syntax #here3

      class << self

        def for x
          new.__init_for_atom x
        end

        attr_reader :the_empty_node
        private :new
      end  # >>

      def initialize
        @_do_be_fancy = true
      end

      def __init_for_atom x  # #here1
        @function_is_spent = true
        @value_x = x
        self
      end

      @the_empty_node = self.for( nil ).freeze

      def with * x_a  # #here3

        o = dup

        o.__do_NOT_be_fancy

        _kp = o.send :process_argument_scanner_fully, scanner_via_array( x_a )

        _kp && o
      end

      def __do_NOT_be_fancy
        @_do_be_fancy = false
      end

      def as_attributes_actor_parse_and_normalize scn  # #here2

        if remove_instance_variable :@_do_be_fancy
          @value_x = scn.gets_one
        end
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
