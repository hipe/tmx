module Skylab::Cull

  module Models_::Upstream

    class << self

      def via_persistable_primitive_name_value_pair_stream_
        _by do |o|
          yield FacadeForUnmarshal___.new o
        end
      end

      def define
        _by do |o|
          yield FacadeForEdit___.new o
        end
      end

      def _by
        Here_::Adapter_via_ActionArguments___.call_by do |o|
          yield o  # hi.
        end
      end
    end  # >>

    # ==

    class FacadeForUnmarshal___

      def initialize o
        @_magnet = o
      end

      def name_value_pair_stream= st
        @_magnet.these_name_value_pairs = st
      end

      def survey_path= su_path
        @_magnet.derelativize_by = -> rel_path do
          ::File.expand_path rel_path, su_path
        end
        su_path
      end

      def filesystem= fs
        @_magnet.filesystem = fs
      end

      def listener= p
        @_magnet.listener = p
      end
    end

    # ==

    class FacadeForEdit___

      # interchange generic parameters for specific parameters:
      #
      #   - route incoming generic parameter names to silo-specific names.
      #
      #   - manifold service instances into their requisite parts.. etc

      def initialize o
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
