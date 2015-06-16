require_relative '..'
require 'skylab/callback/core'

module Skylab

  module MetaHell  # welcome to meta hell. please read [#041] #storypoint-005

    # (this file is temporary to this phase)

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
