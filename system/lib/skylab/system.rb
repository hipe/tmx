require 'skylab/callback'

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

    def test_support  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
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

      def find * x_a, & x_p

        _lib( :Find ).for_mutable_args_ x_a, & x_p
      end

      def grep * x_a, & x_p

        _lib( :Grep ).for_mutable_args_ x_a, & x_p
      end

      def IO
        _common( :IO )
      end

      def new_pather

        # this is a transitional, deprecated-at-once method. clients that
        # use this should refactor to construct the pather by supplying
        # values from conduits instead because the below is not test-friendly.

        Home_::Filesystem::Pather.new ::ENV[ 'HOME' ], ::Dir.pwd
      end

      def open2 cmd_s_a, sout=nil, serr=nil, opt_h=nil, & x_p
        Home_::Open2.new( cmd_s_a, sout, serr, opt_h, & x_p ).execute
      end

      def patch * x_a, & x_p

        _common( :Patch ).call_via_arglist x_a, & x_p
      end

      def popen3 * cmd_s_a, & please_not_this_way
        Home_.lib_.open3.popen3( * cmd_s_a, & please_not_this_way )
      end

      def processes
        _common :Processes
      end

      def which s
        _common( :Which ).call s
      end

      def _common sym

        @_h.fetch sym do
          @_h[ sym ] = _lib( sym ).new self
        end
      end

      def _lib sym
        Services___.const_get sym, false
      end

      def test_support  # :+[#ts-035]
        Home_.test_support
      end

      self
    end.new
  end

  # ==

  Autoloader_ = Callback_::Autoloader

  module Filesystem  # (stowaway)

    module Normalizations

      Autoloader_[ self ]
    end

    CONST_SEP_ = '::'
    DIRECTORY_FTYPE = 'directory'
    DOT_ = '.'
    DOT_DOT_ = '..'
    FILE_FTYPE = 'file'
    FILE_SEPARATOR_BYTE = ::File::SEPARATOR.getbyte 0

    Autoloader_[ self ]
  end

  # ==

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Attributes_ = -> h do
    Home_.lib_.fields::Attributes[ h ]
  end

  Autoloader_[ self, Callback_::Without_extension[ __FILE__ ] ]

  Autoloader_[ Services___ = ::Module.new ]

  ACHIEVED_ = true
  CLI = nil  # for host
  EMPTY_A_ = [].freeze
  EMPTY_S_ = ''.freeze
  Home_ = self
  KEEP_PARSING_ = true
  NEWLINE_ = "\n"
  NIL_ = nil
  NILADIC_TRUTH_ = -> { true }
  NOTHING_ = nil
  SPACE_ = ' '.freeze
  UNABLE_ = false
end

# :#tombstone: failed to start service
# :#tombstone: we used to build getters dynamically for the toplevel services
