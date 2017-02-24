require 'skylab/common'

module Skylab::System

  # see [#001] #section-1 (introduction)

  class << self

    def lib_

      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end

    def services
      Services___.instance
    end

    def test_support  # #[#ts-035]
      if ! Home_.const_defined? :TestSupport
        require_relative '../../test/test-support'
      end
      Home_::TestSupport
    end
  end  # >>

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  # -

    class Services___

      # #section-2 intro to what was formerly calle the "front"

      class << self
        def instance
          @___instance ||= new
        end
        private :new
      end

      def initialize
        @_dereference = :__dereference_initially
      end

      def defaults
        _service :Defaults
      end

      def diff
        _service :Diff
      end

      def environment
        _service :Environment
      end

      def filesystem * x_a, & x_p

        _service( :Filesystem ).for_mutable_args_ x_a, & x_p
      end

      def find * x_a, & x_p

        _lib( :Find ).for_mutable_args_ x_a, & x_p
      end

      def grep * x_a, & x_p

        _lib( :Grep ).for_mutable_args_ x_a, & x_p
      end

      def IO
        _service :IO
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

        _service( :Patch ).call_via_arglist x_a, & x_p  # Patch
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
        _service :Processes
      end

      def which s
        _service( :Which ).call s
      end

      def test_support  # :+[#ts-035]
        Home_.test_support
      end

      # --

      def _service const
        send @_dereference, const
      end

      def __dereference_initially const

        @_branch_module = Home_

        @_loadable_references = Home_.lib_.plugin::Magnetics::
            OperatorBranch_via_DirectoryOneDeeper.
        define do |o|

          # NOTE: the only use this has to us for now is constituency validation

          o.system = ::Dir
          o.entry = 'service.rb'
          o.branch_module = @_branch_module
        end

        @_service_cache = ::Hash.new do |h, k|
          x = __build_service k
          h[k] = x
          x
        end
        @_dereference = :__dereference_subsequently
        send @_dereference, const
      end

      def __dereference_subsequently const
        @_service_cache[ const ]
      end

      def __build_service const

        _normal_symbol = const.downcase  # ..

        @_loadable_references.dereference _normal_symbol

        _subsystem_mod = @_branch_module.const_get const, false

        _service = _subsystem_mod.const_get( :Service, false ).new self

        _service  # hi.
      end

      def _lib sym
        Home_.const_get sym, false
      end
    end
  # -

  # ==

  Autoloader_ = Common_::Autoloader

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

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  Basic_ = Lazy_.call do
    Home_.lib_.basic
  end

  # --

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    define_singleton_method :_memoize, Common_::Memoize

    Attributes_stack_frame = -> *a do
      Fields[]::Attributes::Stack::CommonFrame.call_via_arglist a
    end

    string_scanner_class = _memoize do
      require 'strscan'
      ::StringScanner
    end

    String_scanner = -> s do
      string_scanner_class[].new s
    end

    Tmpdir = _memoize do
      require 'tmpdir'
      ::Dir.tmpdir
    end

    # --

    Autonomous_component_system = sidesys[ :Autonomous_Component_System ]
    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]  # used in tests too
    Fields = sidesys[ :Fields ]
    File_utils = stdlib[ :FileUtils ]
    Human = sidesys[ :Human ]
    Open3 = stdlib[ :Open3 ]
    Parse_lib = sidesys[ :Parse ]
    Pathname = stdlib[ :Pathname ]
    Plugin = sidesys[ :Plugin ]
    Shellwords = stdlib[ :Shellwords ]
    String_IO = stdlib[ :StringIO ]
  end

  # --

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ] ]

  ACHIEVED_ = true
  CLI = nil  # for host
  DASH_ = '-'
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { NOTHING_ }
  EMPTY_S_ = ''.freeze
  FILE_SEPARATOR_BYTE_ = ::File::SEPARATOR.getbyte 0
  Home_ = self
  KEEP_PARSING_ = true
  NEWLINE_ = "\n"
  NIL_ = nil
  NILADIC_TRUTH_ = -> { true }
  NOTHING_ = nil
  SimpleModel_ = Common_::SimpleModel
  SPACE_ = ' '.freeze
  UNABLE_ = false
  UNDERSCORE_ = '_'

  def self.describe_into_under y, _
    y << "abstraction layer for accessing facilities on the underlying system,"
    y << "most commonly the filesystem, `find` and `grep`"
  end
end
# :#tombstone: failed to start service
# :#tombstone: we used to build getters dynamically for the toplevel services
