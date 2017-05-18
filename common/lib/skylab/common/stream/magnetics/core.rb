module Skylab::Common

  module Stream::Magnetics

    # (this node used to define stream itself)

    # ==

    class ResourceReleasingStream_via

      # just a purile DSL with a purile exposures proxy to make streams
      # that release arbitrary resources (like a system process) prettier
      # looking and easier to define.

      class << self
        def [] p, cls
          new( p, cls ).execute
        end
      end  # >>

      def initialize p, cls
        p[ self ]
        @stream_class = cls
      end

      def upstream_as_resource_releaser_by & p
        @__rr = ResourceReleaser___.new( & p ) ; nil
      end

      def stream_by & p
        @__sp = p
      end

      def execute
        _rr = remove_instance_variable :@__rr
        @stream_class.by _rr, & remove_instance_variable( :@__sp )
      end

      class ResourceReleaser___ < ::Proc
        alias_method :release_resource, :call
      end
    end

    # ==

      Stream_via_Range = -> map, r, cls do

        if r.begin < r.end
          amount_to_add = 1
          d = r.begin - amount_to_add
          last = if r.exclude_end?
            r.end - amount_to_add
          else
            r.end
          end
        else
          amount_to_add = -1
          d = r.begin - amount_to_add
          last = if r.exclude_end?
            r.end - amount_to_add
          else
            r.end
          end
        end
        st = cls.by do
          if last != d
            d += amount_to_add
          end
        end
        if map
          st.map_reduce_by( & map )
        else
          st
        end
      end

      Stream_via_Times = -> map, d, cls do
        offset = -1 ; last = d - 1
        st = cls.by do
          if last != offset
            offset += 1
            offset
          end
        end
        if map
          st.map_reduce_by( & map )
        else
          st
        end
      end

    # ==

    MinimalStream_via = -> x do

      # #[#056.1] strain: similar try-convert's for stream
      # (old - moved here from sibling near "map expanded stream by..)

      if x.respond_to? :each_index
        Home_.lib_.basic::List::LineStream_via_Array[ x ]

      elsif x.respond_to? :read
        Home_.lib_.system_lib::IO::LineStream_via_PageSize.call_by do |o|
          o.filehandle = x
        end
      elsif x.respond_to? :each
        Home_.lib_.basic::Enumerator::LineStream_via_Enumerator[ x ]

      elsif x.respond_to? :ascii_only?
        Home_.lib_.basic::String::LineStream_via_String[ x ]

      else
        UNABLE_
      end
    end

    # ==

    class EachPairable_via_Stream < MonadicMagneticAndModel

      def initialize st
        @stream = st
      end

      def each_pair
        st = remove_instance_variable :@stream
        while pair = st.gets
          yield pair.name_symbol, pair.value
        end
        NIL
      end
    end

    # ==
    # ==
  end
end
# #tombstone-A: `length_exceeds` (was used 1x), `Puts_Wrapper` (0x)
