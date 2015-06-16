require_relative '..'
require 'skylab/callback/core'

module Skylab

  module MetaHell  # welcome to meta hell. please read [#041] #storypoint-005

    class << self

      def function_chain * a
        if a.length.zero?
          MetaHell_::Lib__::Function_chain
        else
          MetaHell_::Lib__::Function_chain[ a, a.shift ]
        end
      end

      def import_contants from_mod, i_a, to_mod
        MetaHell_::Lib__::Import_constants[ from_mod, i_a, to_mod ]
      end

      def import_methods from_mod, i_a, priv_pub, to_mod
        MetaHell_::Lib__::Import_methods[ from_mod, i_a, priv_pub, to_mod ]
      end

      def lib_
        @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
          self::Lib_, self )
      end

      def method_is_defined_by_module i, mod
        mod.method_defined? i or mod.private_method_defined? i
      end

      def say_not_found k, a
        MetaHell_::Lib__::Say_not_found[ a, k ]
      end

      def strange * a
        lib_.basic::String.via_mixed.call_via_arglist a
      end

      def touch_const_reader a, b, c, d, e
        MetaHell_::Lib__::Touch_const_reader[ a, b, c, d, e ]
      end

      def without_warning & p
        MetaHell__::Lib__::Without_warning[ p ]
      end
    end

    Callback_ = ::Skylab::Callback
    Autoloader_ = ::Skylab::Callback::Autoloader
    DASH_ = '-'.getbyte 0
    EMPTY_A_ = [].freeze  #storypoint-015 explains this OCD
    EMPTY_P_ = -> { }
    IDENTITY_ = -> x { x }
    KEEP_PARSING_ = true
    MetaHell_ = self
    NIL_ = nil
    MONADIC_EMPTINESS_ = -> _ { }
    MONADIC_TRUTH_ = -> _ { true }
    Autoloader_[ self, ::File.dirname( __FILE__ ) ]
  end
end

module Skylab::MetaHell

  module Bundle  # :[#001].

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
          # #storypoint-110 how bundle name resolution works
          str = const_i.to_s
          _k = if UCASE_RANGE__.include? str.getbyte( 1 )
            const_i
          else
            str[ 0 ] = str[ 0 ].downcase
            str.intern
          end
          h[ _k ] = const_get const_i
        end
        h
      end
      #
      UCASE_RANGE__ = 'A'.getbyte( 0 ) .. 'Z'.getbyte( 0 )
      #
      def handle_bundle_not_found h, k  # :+#bundle-multiset-API
        raise ::KeyError, say_bundle_not_found( k, h.keys )
      end

      def say_bundle_not_found k, a  # :+#bundle-multiset-API
        MetaHell_.say_not_found k, a
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

    module Directory

      def self.[] mod
        Autoloader_[ mod ]
        Multiset[ mod ]
        mod.extend self ; nil
      end

    private

      def build_hard_bundle_fetcher  # #bundle-multiset-API
        soft_bundle_fetcher  # kick
        -> i do
          const_i = @h[ i ] or raise ::KeyError, say_bundle_not_found( i, @a )
          const_get const_i, false
        end
      end

      def build_soft_bundle_fetcher  # #bundle-multiset-API
        @a = [ ] ; @h = { }
        dir_pathname.children( false ).each do |pn|
          stem = pn.sub_ext( '' ).to_s
          WHITE_STEM_RX__ =~ stem or next
          stem.gsub! '-', '_'
          meth_i = stem.intern
          @a << meth_i
          @h[ meth_i ] = Constify__[ stem ]
        end
        -> i do
          const_i = @h[ i ]
          const_i and const_get const_i, false
        end
      end
      WHITE_STEM_RX__ = /[^-]\z/
      Constify__ = -> stem do
        "#{ stem[ 0 ].upcase }#{ stem[ 1 .. -1 ] }".intern
      end
    end
  end
end

