module Skylab::Common

  class Stream::Magnetics::RandomAccessImmutable_via_Stream < SimpleModel

    # :[#016.4] (refereneced 1x only, by [sy])

    # -

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

      include Box::InstanceMethods

      def offset_of k
        if @_cache.key? k
          @_order.index k
        else
          had = true
          _fetch_when_not_in_cache k do
            had = false
          end
          if had
            @_order.index k
          else
            NOTHING_  # hi.
          end
        end
      end

      def fetch k, & p
        had = true
        x = @_cache.fetch k do
          had = false
        end
        if had
          x
        else
          _fetch_when_not_in_cache k, & p
        end
      end

      def _fetch_when_not_in_cache k, & p
        if @_open
          __lookup p, k
        elsif p
          p[]
        else
          raise _key_error k
        end
      end

      def __lookup p, k
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

      def to_key_scanner
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
# #tombstone-A: used to use iambic attributes, removed TONS of unused method
