require 'skylab/common'

module Skylab::TMX

  def self.describe_into_under y, _
    y << "an attempt at making command-line apps of the skylab universe"
    y << "accessible from one entrypoint."
  end

  Common_ = ::Skylab::Common
  Lazy_ = Common_::Lazy

  class << self

    def development_directory_json_file_stream__ & emit

      # (compare `installation_.to_sidesystem_load_ticket_stream`)

      _dir = __development_directory
      glob = ::File.join _dir, '*', METADATA_FILENAME
      files = ::Dir.glob glob
      if files.length.zero?
        emit.call :error, :expression, :zero_nodes do |y|
          y << "found no files for #{ glob }"
        end
        UNABLE_
      else
        Stream_[ files ]
      end
    end

    def build_sigilized_sidesystem_stream_plus stem

      # what tmx reports as the "sidesystem stream" is based on the gems
      # found to be installed. you may want to have included as a sigilized
      # sidesystem a sidesystem that has not yet been made a gem, for example
      # if you are making it into a gem..

      st = to_sidesystem_load_ticket_stream
      bx = Common_::Box.new
      begin
        lt = st.gets
        bx.add lt.entry_string, lt
      end while nil

      if stem and ! bx.has_name stem
        stemmish = Stemmish___[ stem ]
        bx.add stemmish.entry_string, stemmish
      end

      _anything = Home_::Models::Sigil.via_stemish_box bx

      _anything.to_stream
    end

    Stemmish___ = ::Struct.new :stem

    def lookup_sidesystem entry_s
      self._NOT_USED
      installation_.lookup_reflective_sidesystem__ entry_s
    end

    def to_reflective_sidesystem_stream
      installation_.to_reflective_sidesystem_stream__
    end

    def to_sidesystem_load_ticket_stream
      installation_.to_sidesystem_load_ticket_stream
    end

    define_method :application_kernel_, ( Lazy_.call do
      Home_.lib_.brazen::Kernel.new Home_
    end )

    def installation_
      @___installation ||= __build_installation
    end

    def __build_installation

      Home_::Models_::Installation.define do |o|
        __ o
      end
    end

    def __ o
      o.single_gems_dir = ::File.join ::Gem.paths.home, 'gems'
      o.participating_gem_prefix = 'skylab-'
      o.participating_gem_const_head_path = [ :Skylab ]
      o.participating_exe_prefix = 'tmx-'
    end

    define_method :__development_directory, ( Lazy_.call do

      _dir = Home_.sidesystem_path_

      _norm_dir = Home_.path_normalizer_.normalize_absolute_path _dir

      ::File.dirname _norm_dir
    end )

    def test_support  # #[#ts-035]
      @___test_support ||= begin
        require_relative '../../test/test-support' ; Home_::TestSupport
      end
    end

    define_method :path_normalizer_, ( Lazy_.call do
      # see [#tm-013.1] and [#cm-017]
      require 'skylab/code_metrics/operations-/mondrian'  # yikes
      _Lib = ::Skylab_CodeMetrics_Operations_Mondrian_EarlyInterpreter
      _Lib::PathNormalizer.new nil, nil  # do_debug, debug_IO
    end )

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        self::Lib_, self )
    end

    def sidesystem_path_
      @___ssp ||= ::File.expand_path '../../..', dir_path
    end
  end  # >>

  Autoloader_ = Common_::Autoloader

  # ==

  DEFINITION_FOR_THE_METHOD_CALLED_PARSE_INTO_ = -> ivar, * x_a do

    req = @argument_scanner.parse_parse_request x_a

    x = @argument_scanner.parse_primary_value_via_parse_request req

    if x
      if req.successful_result_will_be_wrapped
        x = x.value_x
      end
      instance_variable_set ivar, x
      ACHIEVED_
    end
  end

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x
      instance_variable_set ivar, x ; ACHIEVED_
    else
      x
    end
  end

  # == model support

  class SimpleModel_  # EXPERIMENT import from [tab]

    class << self
      alias_method :define, :new
      undef_method :new
    end  # >>

    def initialize  # (a suggestion)
      yield self
      freeze
    end

    private :dup
  end

  # ==

  module Models_
    Autoloader_[ self ]
    lazily :GemNameElements do
      Zerk_lib_[]::Models::Sidesystem::GemNameElements
    end
    lazily :LoadTicket do
      Zerk_lib_[]::Models::Sidesystem::LoadTicket
    end
  end

  # ==

  Zerk_lib_ = Lazy_.call do
    mod = Autoloader_.require_sidesystem :Zerk
    Zerk_ = mod
    mod
  end

  Stream_ = -> a, & p do
    Common_::Stream.via_nonsparse_array a, & p
  end

  Basic_ = Lazy_.call do
    lib_.basic
  end

  # ==

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]

    Human = sidesys[ :Human ]

    System = -> do
      System_lib[].services
    end

    System_lib = sidesys[ :System ]

    JSON = stdlib[ :JSON ]

    Test_support = sidesys[ :TestSupport ]
  end

  # ==

  ACHIEVED_ = true
  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]
  DASH_ = '-'
  DOT_ = '.'
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> { NOTHING_ }
  EMPTY_S_ = ''
  Home_ = self
  KEEP_PARSING_ = true
  METADATA_FILENAME = '.for-tmx-map.json'
  MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
  NEWLINE_ = "\n"
  NIL_ = nil
  NOTHING_ = nil
  SPACE_ = ' '
  UNABLE_ = false
  UNDERSCORE_ = '_'
end
