module Skylab::Brazen

  module API  # see [#050]

    class << self

      def bound_call_session
        API::Produce_bound_call__
      end

      def call * x_a, & oes_p
        bc = Home_.application_kernel_.bound_call_via_mutable_iambic x_a, & oes_p
        bc and bc.receiver.send bc.method_name, * bc.args
      end

      def exit_statii
        Exit_statii___[]
      end

      def expression_agent_class
        API::Expression_Agent__
      end

      def expression_agent_instance  # #note-015
        @expag ||= expression_agent_class.new :_no_kernel_
      end

      def members
        singleton_class.instance_methods( false ) - [ :members ]
      end
    end  # >>

    teea = nil
    build_the_empty_expression_agent = -> do
      class Empty_Expag < ::BasicObject
        def calculate y, & p
          instance_exec y, & p
        end
        new
      end
    end
    API.send :define_singleton_method, :the_empty_expression_agent do
      teea ||= build_the_empty_expression_agent[]
    end

    Exit_statii___ = Common_::Lazy.call do

      class Exit_Statii____

        h = {
          # order matters: more specific error codes may trump more general ones
          generic_error: ( d = 5 ),
          error_as_specificed: ( d += 1 ),
          invalid_property_value: ( d += 1 ),
          extra_properties: ( d += 1 ),
          missing_required_properties: ( d += 1 ),
          actual_property_is_outside_of_formal_property_set: ( d += 1 ),
          resource_not_found: ( d += 1 ),
          resource_exists: ( d += 1 ),
        }.freeze

        define_method :[], & h.method( :[] )
        define_method :fetch, & h.method( :fetch )
        define_method :members, & h.method( :keys )

        self
      end.new
    end
  end
end
