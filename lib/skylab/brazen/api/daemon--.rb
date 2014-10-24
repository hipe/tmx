module Skylab::Brazen

  module API  # see [#050]

    class << self

      def exit_statii
        Exit_statii__[]
      end

      def module_methods
        MM__
      end

      def expression_agent_instance  # #note-015
        @expag ||= expression_agent_class.new application_kernel
      end
    end

    extend module MM__

      def call * x_a, & p
        bc = _API_daemon.produce_bound_call_via_iambic_and_proc x_a, p
        bc and bc.receiver.send bc.method_name, * bc.args
      end

      def application_kernel
        _API_daemon.application_kernel
      end

      def _API_daemon
        @API_daemon ||= bld_API_daemon
      end

    private

      def bld_API_daemon
        Daemon__.new Brazen_.name_library.surrounding_module self
      end

    public

      def debug_IO
        @debug_IO ||= Lib_::HL__[]::System::IO.some_stderr_IO
      end

      def expression_agent_class
        const_get :Expression_Agent__, false
      end

      self
    end

    class Daemon__

      def initialize mod
        @mod = mod
        @app_kernel = @mod.const_get( :Kernel_, false ).new @mod ; nil
      end

      def produce_bound_call_via_iambic_and_proc x_a, p
        API::Produce_bound_call__[ x_a, p, @app_kernel, @mod ]
      end

      def application_kernel
        @app_kernel
      end
    end

    Exit_statii__ = Callback_.memoize do
      class Exit_Statii__
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
        self
      end.new
    end

    OK_ = true
  end
end
