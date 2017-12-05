module Skylab::Brazen

  module API  # see [#050]

    class << self

      def call * x_a, & p
        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & p
        bc and bc.receiver.send bc.method_name, * bc.args
      end

      def exit_statii
        Exit_statii___[]
      end

      def expression_agent_instance  # see [#050.B]
        @___expag ||= __expag
      end

      def __expag
        Zerk_lib_[]::API::InterfaceExpressionAgent::
          THE_LEGACY_CLASS.via_expression_agent_injection :_no_kernel_for_expag_for_BR_
      end

      def the_empty_expression_agent
        THE_EMPTY_EXPRESSION_AGENT_
      end
    end  # >>

    Exit_statii___ = Common_::Lazy.call do

      class Exit_Statii____

        h = {
          # order matters: more specific error codes may trump more general ones
          generic_error: ( d = 5 ),
          error_as_specificed: ( d += 1 ),
          invalid_property_value: ( d += 1 ),
          unrecognized_argument: ( d += 1 ),
          missing_required_properties: ( d += 1 ),
          actual_property_is_outside_of_formal_property_set: ( d += 1 ),
          resource_not_found: ( d += 1 ),
          resource_existed: ( d += 1 ),
        }.freeze

        # h[ :item_not_found ] = h[ :unrecognized_argument ]

        define_method :[], & h.method( :[] )
        define_method :fetch, & h.method( :fetch )
        define_method :members, & h.method( :keys )

        self
      end.new
    end
  end
end
