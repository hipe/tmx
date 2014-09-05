module Skylab::TanMan

  module API

    class << self

      def call * x_a, & p
        bc = _API_daemon.produce_bound_call_via_iambic_and_proc x_a, p
        bc and bc.receiver.send bc.method_name, * bc.args
      end

      def produce_application_kernel
        _API_daemon.produce_application_kernel
      end

    private

      def _API_daemon
        @API_daemon ||= Daemon__.new( TanMan_ )
      end
    end

    class Daemon__

      def initialize mod
        @mod = mod
        @app_kernel = @mod.const_get( :Kernel_, false ).new @mod ; nil
      end

      def produce_bound_call_via_iambic_and_proc x_a, p
        @mod::API::Produce_bound_call__[ x_a, p, @app_kernel, @mod ]
      end

      def produce_application_kernel
        @app_kernel
      end
    end

    Bound_Call_ = ::Struct.new :receiver, :method_name, :args
    IDENTITY_ = -> x { x }
    OK_ = true
    UNABLE_ = false
  end
end
