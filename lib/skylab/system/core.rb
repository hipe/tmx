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

      def initialize
        @_h = {}
      end

      def defaults
        _common :Defaults
      end

      def diff
        _common :Diff
      end

      def environment
        _common :Environment
      end

      def filesystem * x_a, & x_p

        _common( :Filesystem ).for_mutable_args_ x_a, & x_p
      end

      def IO
        _common( :IO )
      end

      def open2 cmd_s_a, sout=nil, serr=nil, & x_p
        Home_::Sessions__::Open2.new( cmd_s_a, sout, serr, & x_p ).execute
      end

      def which s
        _common( :Which ).call s
      end

      def _common sym

        @_h.fetch sym do
          @_h[ sym ] = Services___.const_get( sym, false ).new self
        end
      end

      def test_support  # :+[#ts-035]

        ::Kernel.require_relative 'test/test-support'

        Home_::TestSupport
      end

      self
    end.new
  end

  Autoloader_ = Callback_::Autoloader

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  Autoloader_[ Services___ = ::Module.new, :boxxy ]

  ACHIEVED_ = true
  CLI = nil  # for host
  EMPTY_S_ = ''.freeze
  Home_ = self
  KEEP_PARSING_ = true
  NEWLINE_ = "\n"
  NIL_ = nil
  NILADIC_TRUTH_ = -> { true }
  SPACE_ = ' '.freeze

end

# :#tombstone: failed to start service
# :#tombstone: we used to build getters dynamically for the toplevel services
