module Skylab::Brazen

  module API  # see [#050]

    class << self

      def bound_call_session
        API::Produce_bound_call__
      end

      def exit_statii
        Exit_statii__[]
      end

      def module_methods
        MM__
      end

      def expression_agent_instance  # #note-015
        @expag ||= expression_agent_class.new application_kernel
      end

      def two_stream_event_expresser
        API::Produce_bound_call__::Two_Stream_Event_Expresser
      end
    end

    extend module MM__

      def members
        [ :application_kernel, :call ]
      end

      def call * x_a, & x_p
        bc = _API_daemon.produce_bound_call_via_mutable_iambic x_a, & x_p
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
        @debug_IO ||= LIB_.system.IO.some_stderr_IO
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

      def produce_bound_call_via_mutable_iambic x_a, & x_p

        if x_p
          x_a.push :on_event_selectively, x_p
        end

        API::Produce_bound_call__[ x_a, @app_kernel, @mod ]
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
        define_method :members, & h.method( :keys )

        self
      end.new
    end

    OK_ = true
  end
end
