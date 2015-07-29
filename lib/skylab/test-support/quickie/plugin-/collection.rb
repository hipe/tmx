module Skylab::TestSupport

  module Quickie

    class Plugin_::Collection

      def initialize host, mod
        @a = nil
        @__cool_pool = Cool_Pool__.new host.y
        @h = nil
        @host = host
        @mod = mod
      end

      def _host  # #hacks-only
        @host
      end

      def a_
        @a
      end

      def _init_hash  # assume @h is nil

        ok = if @a
          ACHIEVED_
        else
          load_all__
        end

        if ok
          h = {}
          @a.each_with_index do | pu, d |
            h[ pu.plugin_symbol ] = d
          end
          @h = h
        else
          @h = ok
        end
        NIL_
      end

      def load_all__
        a = __build_array
        if a
          @a = a
          ACHIEVED_
        else
          a
        end
      end

      def __build_array

        mod = @mod

        proto = Plugin_::Adapter.new @__cool_pool, self, @host, @mod

        mod.constants.map do | const |
          proto.new const
        end
      end

      def keys
        @h.nil? && _init_hash
        @h.keys
      end

      def [] i
        @h.nil? && _init_hash
        @a.fetch( @h.fetch i )
      end

      # ~

      class Cool_Pool__
        def initialize y
          @back_a = [] ; @y = y ; nil
        end
        def build_fuzzy_flag a
          back = Fuzzy_Flag_Back__.new @back_a.length,  a
          @back_a[ back.identifier_index ] = back
          Fuzzy_Flag_Front__.new back, self
        end
        def build_required_arg_switch x
          Required_Arg_Switch__.new x
        end
        def any_first_idx_in_inp back, sig
          match =
            any_unresolved_match_from_matcher_at_idx back.identifier_index, sig
          match and match.resolve
        end
        def any_unresolved_match_from_matcher_at_idx d, sig
          back = @back_a.fetch d ; rx_a = sig.fuzzified ; s_a = back.s_a
          formal_variant_s = nil
          any_idx = rx_a.index do |rx|
            rx or next
            formal_variant_s = s_a.detect( & rx.method( :=~ ) )
          end
          any_idx and
            Unresolved_Match__.new self, back, sig, formal_variant_s, any_idx
        end
        def matcher_count
          @back_a.length
        end
        def ambiguous_unresolved_matches a
          @y << say_ambiguous( a ) ; nil
        end
      private
        def say_ambiguous a
          unr = a.first
          ambi_s = unr.sig.input[ unr.index_in_sig ]
          a_ = a.map do |unr_|
            unr_.formal_variant_s.inspect
          end
          _or = a_ * ' or '
          _mm = "(from #{ unr.matcher_moniker })"
          "ambiguous term #{ ambi_s.inspect }. did you mean #{ _or }? #{ _mm }"
        end
      end

      class Unresolved_Match__
        def initialize pool, back, sig, formal_variant_s, index
          @back = back ; @d = index
          @formal_variant_s = formal_variant_s
          @pool = pool ; @provided_s = sig.input[ @d ] ; @sig = sig
        end
        attr_reader :formal_variant_s, :sig
        def index_in_sig
          @d
        end
        def resolve
          if is_exact_match
            @d
          else
            rslv_when_fuzzy
          end
        end
        def is_exact_match
          @formal_variant_s == @provided_s
        end
      private
        def rslv_when_fuzzy
          idx_a = @pool.matcher_count.times.to_a
          idx_a[ @back.identifier_index ] = nil
          idx_a.compact!
          @otr_a = idx_a.reduce [] do |m, x|
            match = @pool.any_unresolved_match_from_matcher_at_idx x, @sig
            if match
              if match.is_exact_match
                break
              else
                m << match
              end
            end ; m
          end
          if @otr_a
            if @otr_a.length.zero? then @d else
              when_ambiguous
            end
          end
        end
        def when_ambiguous
          @otr_a.unshift self
          @pool.ambiguous_unresolved_matches @otr_a
        end
      public
        def matcher_moniker
          @back.back_moniker
        end
      end

      class Fuzzy_Flag_Front__

        def initialize back, pool
          @back = back ; @pool = pool ; nil
        end

        def any_first_index_in_input sig
          @pool.any_first_idx_in_inp @back, sig
        end

        def some_opts_moniker
          @back.some_opts_mnkr
        end
      end

      class Fuzzy_Flag_Back__
        def initialize identifier_index, a
          @identifier_index = identifier_index ; @s_a = a
        end
        attr_reader :identifier_index, :s_a
        def back_moniker
          @s_a.last
        end
        def some_opts_mnkr
          @some_opts_mnkr ||= bld_options_moniker
        end
      private
        def bld_options_moniker
          @s_a * '|'
        end
      end

      class Required_Arg_Switch__
        def initialize s
          @s = s
          @rx = /\A#{ ::Regexp.escape s }=/
        end

        attr_reader :s

        def any_first_index_in_input sig
          a = sig.input
          a.length.times.detect do |d|
            @rx =~ a.fetch( d )
          end
        end

        def any_several_indexes_in_input sig
          a = sig.input
          a.length.times.reduce nil do |m, d|
            if @rx =~ a.fetch( d )
              m ||= []
              m.push d
            end ; m
          end
        end
      end
    end
  end
end
