module Skylab::Common

  class Stream::Magnetics::OperatorBranch_via_Stream < SimpleModel

    # this is :[#016.4], which is refereneced (only ever) by [sy] which
    # has what is likely an improvement on this implementation, but
    # specific for directory listings at [#sy-040]. either abstract that
    # work up into here, or at least duplicate its test "galley" here.

      def initialize
        yield self
        @_cache = {}
        @_open = true
        @_order = []
      end

      attr_writer(
        :key_method_name,
        :upstream,
      )

      # -- read

      def offset_via_reference k  # [ac]
        if @_cache.key? k
          @_order.index k
        else
          had = true
          _lookup_when_not_in_cache k do
            had = false
          end
          if had
            @_order.index k
          else
            NOTHING_  # hi.
          end
        end
      end

      def to_dereferenced_item_stream
        scn = __to_key_scanner
        Stream.by do
          unless scn.no_unparsed_exists
            _lookup scn.gets_one
          end
        end
      end

      def lookup_softly k
        _lookup k do
          NOTHING_
        end
      end

      def _lookup k, & p
        had = true
        x = @_cache.fetch k do
          had = false
        end
        if had
          x
        else
          _lookup_when_not_in_cache k, & p
        end
      end

      def _lookup_when_not_in_cache k, & p
        if @_open
          __lookup_when_open p, k
        elsif p
          p[]
        else
          raise _key_error k
        end
      end

      def __lookup_when_open p, k
        scn = _to_caching_unseen_key_scanner
        begin
          if scn.no_unparsed_exists
            if p
              x = p[]
              break
            end
            raise _key_error k
          end
          this_k = scn.head_as_is
          scn.advance_one
          if k == this_k
            x = @_cache.fetch k
            break
          end
          redo
        end while above
        x
      end

      def __to_key_scanner
        if @_open
          if @_cache.length.zero?
            _to_caching_unseen_key_scanner
          else
            Scanner::CompoundScanner.define do |o|
              o.add_scanner _to_seen_key_scanner
              o.add_scanner _to_caching_unseen_key_scanner  # is this too early?
            end
          end
        else
          _to_seen_key_scanner
        end
      end

      def _key_error k
        ::KeyError.new __say_name_not_found k
      end

      def __say_name_not_found k
        "key not found: #{ k.inspect }"
      end

      def _to_caching_unseen_key_scanner
        m = @key_method_name
        Stream.by do
          x = @upstream.gets
          if x
            k = x.send m
            @_cache[ k ] = x
            @_order.push k
            k
          else
            __close
            STOP_PARSING_
          end
        end.flush_to_scanner
      end

      def _to_seen_key_scanner
        Scanner.via_array @_order
      end

      def __close
        @_open = false
        remove_instance_variable :@upstream
        freeze ; nil
      end

    # -
    # ==

    STOP_PARSING_ = NIL

    # ==
  end
end
# #tombstone-A.2: ENTIRE "random access mutable" file
# #tombstone-A: used to use iambic attributes, removed TONS of unused method
