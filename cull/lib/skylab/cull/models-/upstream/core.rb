module Skylab::Cull

  module Models_::Upstream

    class << self
      def define
        Here_::Adapter_via_ActionArguments___.call_by do |o|
          yield Facade___.new o
        end
      end
    end  # >>

    # ==

    class Facade___

      # interchange generic parameters for specific parameters:
      #
      #   - route incoming generic parameter names to silo-specific names.
      #
      #   - manifold service instances into their requisite parts.. etc

      def initialize o

        # ~(nilify these ourselves for now, to keep things explicit
        o.table_number = nil
        o.upstream_adapter_symbol = nil
        # ~)
        @_magnet = o
      end

      def component_as_primitive_value= s
        @_magnet.upstream_string = s
      end

      def primitive_resources= rsx
        @_magnet.derelativize_by = rsx._derelativize_by_
      end

      def invocation_resources= rsx
        @_magnet.filesystem = rsx.filesystem
        rsx
      end

      def listener= p
        @_magnet.listener = p
      end
    end

    # ==

    module Adapters__
      Autoloader_[ self, :boxxy ]
    end

    # ==

    Here_ = self

    # ==
    # ==
  end
end
# #history-A.1: rewrite from dumb delegator proxy
