require_relative '..'

module Skylab

  module MetaHell  # welcome to meta hell

    MetaHell = self

    EMPTY_A_            =  [ ].freeze  # #ocd
    EMPTY_P_            = ->   { }
    MONADIC_EMPTINESS_  = -> _ { }
    MONADIC_TRUTH_      = -> _ { true }
    IDENTITY_           = -> x { x }
    DASH_               = '-'.getbyte 0

    class Aset_ < ::Proc  # "aset" = "array set" ("[]="), from ruby source
      alias_method :[]=, :call
    end

    # ARE YOU READY TO EAT YOUR OWN DOGFOOD THAT IS MADE OF YOUR BODY

    #                  ~ auto-trans-substantiation ~

    module Autoloader
      include ::Skylab::Autoloader  # [#041]
      ::Skylab::Autoloader[ self ]
    end

    ( MAARS = Autoloader::Autovivifying::Recursive )[ self ]
      # a name this long that is used this often gets its own weird acronym

    def self.Function host, *rest
      self::Function._make_methods host, :public, :method, rest
    end

    Funcy = -> cls do  # apply on a class whose interface is stricly proc-like
      def cls.[] * x_a
        new( * x_a ).execute
      end
    end

    stowaway :Method_Added_Muxer, %i( FUN Fields_ Mechanics_ )  # for now

  end
end

module Skylab::MetaHell

  class Method_Added_Muxer
    # imagine having multiple subscribers to one method added event
    def self.[] mod
      me = self
      mod.module_exec do
        @method_added_muxer ||= begin  # ivar not const! boy howdy watch out
          muxer = me.new self
          singleton_class.instance_method( :method_added ).owner == self and
            fail "sanity - won't overwrite existing method_added hook"
          define_singleton_method :method_added, &
            muxer.method( :method_added_notify )
          muxer
        end
      end
    end
    def initialize mod
      @mod = mod ; @p = nil
    end
    def in_block_each_method_added blk, & do_this
      add_listener do_this
      @mod.module_exec( & blk )
      remove_listener do_this ; nil
    end
    def add_listener p
      @p and fail "implement me - you expected this to actually mux?"
      @p = p
    end
    def remove_listener _
      @p = nil
    end
  private
    def method_added_notify i
      @p && @p[ i ]
      nil
    end
  end

  module Bundle

    module Multiset

      def self.[] mod
        mod.extend self
      end

      def apply_iambic_on_client x_a, client
        h = hard_bundle_fetcher
        begin
          client.module_exec x_a, & h[ x_a.shift ].to_proc
        end while x_a.length.nonzero?
        nil
      end
    private
      def hard_bundle_fetcher
        @hard_bundle_fetcher ||= build_hard_bundle_fetcher
      end
      def build_hard_bundle_fetcher  # :+#bundle-multiset-API
        h = ::Hash.new( & method( :handle_bundle_not_found ) )
        constants.each do |const_i|
          x = const_get const_i, false
          k = if x.respond_to? :bundles_key then x.bundles_key
          elsif UCASE_RANGE__.include? const_i.to_s.getbyte( 1 ) then const_i
          else const_i.downcase end
          h[ k ] = x
        end
        h
      end
      #
      UCASE_RANGE__ = 'A'.getbyte( 0 ) .. 'Z'.getbyte( 0 )
      #
      def handle_bundle_not_found h, k  # :+#bundle-multiset-API
        raise ::KeyError, say_bundle_not_found( h.keys, k )
      end
      #
      def say_bundle_not_found a, k  # :+#bundle-multiset-API
        MetaHell::FUN::Say_not_found[ a, k ]
      end

    public
      def to_proc
        @to_proc ||= build_to_proc_proc
      end
    private
      def build_to_proc_proc  # :+#bundle-multiset-API
        h = soft_bundle_fetcher
        -> a do
          while a.length.nonzero?
            any_to_procable = h[ a[ 0 ] ]
            any_to_procable or break
            a.shift
            module_exec a, & any_to_procable.to_proc
          end ; nil
        end
      end
      def soft_bundle_fetcher
        @soft_bundle_fetcher ||= build_soft_bundle_fetcher
      end
      def build_soft_bundle_fetcher  # :+#bundle-multiset-API
        hard_h = hard_bundle_fetcher
        -> i do
          hard_h.fetch i do end
        end
      end
    end

    class Item_Grammar  # implementation of "the item grammar" [#050]
      class << self
        alias_method :orig_new, :new
        def new adj_i_a, keyword_i, pp_i_a
          ::Class.new( self ).class_exec do
            const_set :ADJ_I_A__, adj_i_a.freeze
            const_set :ADJ_H__, ::Hash[ adj_i_a.map { |i| [ i, i ] } ].freeze
            const_set :Adj_Struct__, Sexp__.new( * adj_i_a )
            const_set :KEYWORD_I__, keyword_i
            const_set :PP_I_A__, pp_i_a.freeze
            const_set :PP_H__, ::Hash[ pp_i_a.map { |i| [ i, true ] } ].freeze
            const_set :PP_Struct__, Sexp__.new( * pp_i_a )
            const_set :SP_Struct__, ::Struct.new( :adj, :keyword_value_x, :pp )
            class << self
              alias_method :new, :orig_new
              alias_method :build_parser_for, :new
            end
            self
          end
        end
      end

      class Sexp__ < ::Struct  # hack a struct to
        # remember what keys were used in its making
        def self.new *a
          if a.length.zero?
            EMPTY_NT__
          else
            super
          end
        end
        def initialize( * )
          @key_set = MetaHell::Services::Set.new
          super
        end
        def keys
          @key_set.to_a
        end
        alias_method :struct_each_pair, :each_pair
        def each_pair &p
          if p
            @key_set.each do |i|
              p[ [ i, self[ i ] ] ]
            end
          else
            enum_for __method__
          end
        end
        def []= i, x
          @key_set.add? i
          super
        end
      end

      EMPTY_NT__ = :this_nonterminal_symbol_is_empty

      def initialize a
        c = self.class ; keyword_i = c::KEYWORD_I__ ; sp_struct = c::SP_Struct__
        adj_h = c::ADJ_H__ ; adj_struct = c::Adj_Struct__
        pp_h = c::PP_H__ ; pp_struct = c::PP_Struct__
        @p = -> do
          a.length.zero? and break
          adj_st = nil
          while adj_h[ a[ 0 ] ]
            (( adj_st ||= adj_struct.new ))[ a.shift ] = true
          end
          if keyword_i == a[ 0 ]
            a.shift
            sp_st = sp_struct.new( adj_st, a.shift )
            pp_st = nil
            while pp_h[ a[ 0 ] ]
              (( pp_st ||= pp_struct.new ))[ a.shift ] = a.shift
            end
            pp_st and sp_st.pp = pp_st
            sp_st
          elsif adj_st
            or_a = [ "encountered unrecognized token `#{ a[ 0 ] }` before #{
             }reaching required token `#{ keyword_i }`" ]
            pp_h.length.nonzero? and or_a << "an adjective among #{
              }(#{ adj_h.keys * ', ' })"
            adj_h.length.nonzero? and or_a << "the start of a #{
              }prepositional phrase from among (#{ pp_h.keys * ', ' })"
            fail( or_a * ' or ' )
          end
        end
        nil
      end

      def []
        @p.call
      end
    end
  end
end
