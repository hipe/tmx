module Skylab::DocTest

  class Operations_::Recurse

    def self.describe_into_under y, expag
      expag.calculate do
        y << "#{ code 'sync' } for an entire directory (EXPERIMENTAL)."
        y << "(currently overloaded with sane defaults, configurable later.)"
      end
    end

    def initialize fs
      @_filesystem = fs
      @list = nil
    end

    def __list__component_association

      yield :description, -> y do
        y << "only output the paths of the participating asset files"
      end

      yield :flag
    end

    def __dir__component_association

      yield :description, -> y do
        y << "the directory zyzzy"
      end

      -> st do
        Common_::Known_Known[ st.gets_one ]
      end
    end

    def execute & oes_p
      @_on_event_selectively = oes_p
      extend ImplementationAssistance___
      execute
    end

    module ImplementationAssistance___
      # don't waste ACS's energy indexing these methods.

      def execute
        _ok = __resolve_path_stream
        _ok && __via_path_stream
      end

      def __resolve_path_stream

        o = Home_::Magnetics_::PathStream_via_Directory_and_PathStreamOptions.new(
          @dir, @_filesystem, & @_on_event_selectively )

        o.etc = :xx

        _if o.execute, :@__path_stream
      end

      def __via_path_stream

        if st
          if @list
            self._RIDE
            st
          else
            ::Kernel._B
          end
        end
      end

      def _if x, ivar
        if x
          instance_variable_set x, ivar ; ACHIEVED_
        else
          x
        end
      end
    end
  end
end
# #tombstone: full rewrite from pre-zerk to zerk
