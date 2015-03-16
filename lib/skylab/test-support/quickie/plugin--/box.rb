module Skylab::TestSupport

  module Quickie

    class Plugin__::Box

      def initialize host, mod
        @a =  nil
        @cool_pool = Cool_Pool__.new host.y
        @h = nil
        @host = host ; @mod = mod
      end

      def _host  # #hacks-only
        @host
      end

      def ready
        @a ||= Get_const_i_a_[ @mod ].map do |const_i|
          Plugin__::Adapter_.
            new( const_i, @mod.const_get( const_i, false ), self )
        end
        true
      end

      Get_const_i_a_ = -> mod do
        ::Dir[ "#{ mod.dir_pathname }/*#{ Autoloader_::EXTNAME }" ].
            reduce [] do |m, path|
          m << LIB_.name_from_path_to_const(
            ::Pathname.new( path ).basename.sub_ext EMPTY_S_ )
        end
      end

      def _a
        @a
      end

      def keys
        @h.nil? and ready_h
        @h.keys
      end

      def [] i
        @h.nil? and ready_h
        @a.fetch( @h.fetch i )
      end

      # ~

      SERVICES_THAT_PLUGINS_WANT__ = %i(
        get_test_path_a
        paystream
        program_moniker
        to_test_path_stream
        y )

      SERVICES_THAT_PLUGINS_WANT__.each do |i|
        define_method i do @host.send i end
      end

      def build_fuzzy_flag a
        @cool_pool.build_fuzzy_flag a
      end

      def build_required_arg_switch a
        @cool_pool.build_required_arg_switch a
      end

      def plugins
        self
      end

      def replace_test_path_s_a path_s_a
        @host.replace_test_path_s_a path_s_a
      end

      def add_iambic x_a
        @host.add_iambic x_a ; nil
      end

    private

      def ready_h  # assume @h is nil
        @h = if ready then
          ::Hash[ @a.each_with_index.map { |x, idx| [ x.plugin_i, idx ] } ]
        else false end
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
