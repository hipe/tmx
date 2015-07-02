require_relative '..'

require_relative '../callback/core'

module Skylab::System

  # see [#001] #section-1 (introduction)

  class << self

    def lib_

      @___lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end

    def services
      Services_front___[]
    end
  end  # >>

  Callback_ = ::Skylab::Callback

  Services_front___ = Callback_.memoize do  # #section-2 intro to the front

    class Front___ < ::BasicObject

      box_mod = Services___

      box_mod.entry_tree.to_stream.each do | entry |

        h = {}
        name = entry.name
        k = name.as_variegated_symbol

        define_method name.as_variegated_symbol do
          h.fetch k do
            x = box_mod.const_get( name.as_const, false ).new self
            h[ k ] = x
            x
          end
        end
      end

      alias_method :IO, :io  # the isomorphicism in this direction is lossy

      # ~ rather then globbing all calls or loading all nodes, do it manually:

      alias_method :___patch, :patch

      def patch * x_a, & x_p
        ___patch.call_via_arglist x_a, & x_p
      end

      alias_method :___which, :which

      def which s
        ___which.call s
      end

      self
    end.new
  end

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Autoloader_[ Services___ = ::Module.new, :boxxy ]

  ACHIEVED_ = true
  KEEP_PARSING_ = true
  EMPTY_S_ = ''.freeze
  NEWLINE_ = "\n"
  NIL_ = nil
  NILADIC_TRUTH_ = -> { true }
  SPACE_ = ' '.freeze
  Home_ = self

end

# :#tombstone: failed to start service
