module Skylab::TMX

  class Models::Front

    Models_ = ::Module.new
    class Models_::As_Kernel

      def initialize front
        @_client = front
      end

      def module
        :__no_module__
      end

      def fast_lookup
        @_client.fast_lookup
      end

      def to_unbound_action_stream
        @_client.unbound_stream_builder.call
      end
    end
  end
end
