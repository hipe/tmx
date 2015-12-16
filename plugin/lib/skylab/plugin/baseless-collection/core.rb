module Skylab::Plugin
  # ->
    class BaselessCollection  # backstory in [#023]

      # -- initialization

      def initialize
        @_index = {}
        @_last_indexed_index = -1
      end

      attr_writer(
        :eventpoint_graph,
        :plugin_services,
        :plugin_tree_seed,
        :modality_const,
      )

      def load_all_plugins

        _ada_cls = Here_::Modality_Adapters_.const_get @modality_const, false

        o = _ada_cls.new
        o.eventpoint_graph = @eventpoint_graph
        o.plugin_collection = self
        o.plugin_services = @plugin_services
        o.plugin_tree_seed = @plugin_tree_seed
        send :"__#{ @modality_const }__specific_adapter_customizations", o

        a = []

        @plugin_tree_seed.constants.each do | plugin_const |
          a.push o.new plugin_const
        end

        @_dependency_adapter_a = a
        @_length = a.length

        ACHIEVED_
      end

      def __CLI__specific_adapter_customizations o
        o.cool_pool = Cool_Pool___.new @plugin_services.y
        NIL_
      end

      # -- access of a single dependency adapter

      def [] lwu_sym  # lowercase with underscores symbol

        x = @_index[ lwu_sym ]
        if ! x
          d = @_last_indexed_index
          begin
            d += 1
            da = @_dependency_adapter_a.fetch d  # etc
            k = da.plugin_symbol
            @_index[ k ] = da
            if lwu_sym == k
              x = da
              @_last_indexed_index = d
              break
            end
            redo
          end while nil
        end
        x
      end

      # -- collection comprehension

      def accept & visit
        @_dependency_adapter_a.each( & visit )
        NIL_
      end

      def to_stream
        Callback_::Stream.via_nonsparse_array @_dependency_adapter_a
      end

      # -- support

      class Cool_Pool___

        def initialize y
          @back_a = [] ; @y = y ; nil
        end

        def build_fuzzy_flag__ a
          back = Fuzzy_Flag_Back__.new @back_a.length,  a
          @back_a[ back.identifier_index ] = back
          Fuzzy_Flag_Front__.new back, self
        end

        def build_required_arg_switch__ x
          Required_Arg_Switch___.new x
        end

        def build_optional_arg_switch__ x
          Optional_Arg_Switch___.new x
        end

        def any_first_match_in_input__ back, sig

          _with_match :build_matchdata, back, sig
        end

        def any_first_index_in_input__ back, sig

          _with_match :resolve, back, sig
        end

        def _with_match m, back, sig

          match = any_unresolved_match_from_matcher_at_idx_(
            back.identifier_index, sig )

          if match
            match.send m
          end
        end

        def any_unresolved_match_from_matcher_at_idx_ d, sig

          back = @back_a.fetch d ; rx_a = sig.fuzzified ; s_a = back.s_a

          formal_variant_s = nil

          any_idx = rx_a.index do |rx|
            rx or next
            formal_variant_s = s_a.detect( & rx.method( :=~ ) )
          end

          if any_idx
            Unresolved_Match__.new self, back, sig, formal_variant_s, any_idx
          end
        end

        def matcher_count
          @back_a.length
        end

        def ambiguous_unresolved_matches a
          @y << ___say_ambiguous( a )
          NIL_
        end

        def ___say_ambiguous a
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

        def index_in_sig
          @d
        end

        def build_matchdata
          self._K
        end

        def resolve
          if is_exact_match
            @d
          else
            ___resolve_when_fuzzy
          end
        end

        def is_exact_match
          @formal_variant_s == @provided_s
        end

        def ___resolve_when_fuzzy

          idx_a = @pool.matcher_count.times.to_a
          idx_a[ @back.identifier_index ] = nil
          idx_a.compact!

          @otr_a = idx_a.reduce [] do |m, x|
            match = @pool.any_unresolved_match_from_matcher_at_idx_ x, @sig
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
              ___when_ambiguous
            end
          end
        end

        def ___when_ambiguous
          @otr_a.unshift self
          @pool.ambiguous_unresolved_matches @otr_a
        end

        def matcher_moniker
          @back.back_moniker
        end

        attr_reader(
          :formal_variant_s,
          :sig,
        )
      end

      class Fuzzy_Flag_Front__

        def initialize back, pool
          @back = back ; @pool = pool ; nil
        end

        def any_first_match_in_input sig
          @pool.any_first_match_in_input__ @back, sig
        end

        def any_first_index_in_input sig
          @pool.any_first_index_in_input__ @back, sig
        end

        def some_opts_moniker
          @back.some_opts_mnkr
        end
      end

      class Fuzzy_Flag_Back__

        def initialize identifier_index, a
          @identifier_index = identifier_index ; @s_a = a
        end

        def back_moniker
          @s_a.last
        end

        def some_opts_mnkr
          @some_opts_mnkr ||= ___build_options_moniker
        end

        def ___build_options_moniker
          @s_a * '|'
        end

        attr_reader(
          :identifier_index,
          :s_a,
        )
      end

      class Switch__  # abstract base

        def initialize s
          @s = s
        end

        def any_first_match_in_input sig

          a = sig.input

          a.length.times.reduce nil do |_, d|

            md = @rx.match a.fetch d
            if md
              break My_Matchdata___[ md, d ]
            end
          end
        end

        My_Matchdata___ = ::Struct.new :matchdata, :index

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

        attr_reader :s
      end

      class Required_Arg_Switch___ < Switch__

        def initialize s
          @rx = /\A#{ ::Regexp.escape s }=/
          super
        end
      end

      class Optional_Arg_Switch___ < Switch__

        def initialize s
          @rx = /\A#{ ::Regexp.escape s }(?:=(?<value>.*))?\z/
          super
        end
      end

      Here_ = self
    end
  # -
end
