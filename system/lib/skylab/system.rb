require 'skylab/common'

module Skylab::System

  # see [#001] #section-1 (introduction)

  class << self

    def lib_

      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
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

  Common_ = ::Skylab::Common

  Services_front___ = Common_.memoize do  # #section-2 intro to the front

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

      def path_looks_absolute path  # ..
        FILE_SEPARATOR_BYTE_ == path.getbyte(0)
      end

      def path_looks_relative path  # ..
        FILE_SEPARATOR_BYTE_ != path.getbyte(0)
      end

      def path_looks_like_directory path
        FILE_SEPARATOR_BYTE_ == path.getbyte(-1)
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

      def inspect
        "#{ Home_.name }::Front___ «instance»"
      end

      def nil?  # [dt] CLI client
        false
      end

      self
    end.new
  end

  # ==

  Autoloader_ = Common_::Autoloader

  module Filesystem  # (stowaway)

    CONST_SEP_ = '::'
    DIRECTORY_FTYPE = 'directory'
    DOT_ = '.'
    DOT_DOT_ = '..'
    FILE_FTYPE = 'file'

    Autoloader_[ self ]
  end

  # ==

  Attributes_actor_ = -> cls, * a do
    Home_.lib_.fields::Attributes::Actor.via cls, a
  end

  Attributes_ = -> h do
    Home_.lib_.fields::Attributes[ h ]
  end

  Path_looks_absolute_ = -> path do
    Home_.services.path_looks_absolute path
  end

  Path_looks_relative_ = -> path do
    Home_.services.path_looks_relative path
  end

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  Autoloader_[ Services___ = ::Module.new ]

  ACHIEVED_ = true
  CLI = nil  # for host
  EMPTY_A_ = [].freeze
  EMPTY_S_ = ''.freeze
  FILE_SEPARATOR_BYTE_ = ::File::SEPARATOR.getbyte 0
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
