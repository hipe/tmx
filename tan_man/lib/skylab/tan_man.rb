require 'skylab/common'

module Skylab::TanMan

  def self.describe_into_under y, _
    y << "manage your tangents visually"
  end

  Common_ = ::Skylab::Common
  Autoloader_ = Common_::Autoloader
  Lazy_ = Common_::Lazy

  class << self

    def lib_
      @___lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_, self )
    end

    def name_function
      @nf ||= Common_::Name.via_module self
    end

    def sidesystem_path_
      @___ssp ||= ::File.expand_path '../../..', __FILE__
    end
  end  # >>

  # ==

  DEFINITION_FOR_THE_METHOD_CALLED_STORE_ = -> ivar, x do
    if x
      instance_variable_set ivar, x ; ACHIEVED_
    else
      x
    end
  end

  # ==

  Byte_downstream_reference_ = Lazy_.call do
    Home_.lib_.basic::ByteStream::DownstreamReference
  end

  Byte_upstream_reference_ = Lazy_.call do
    Home_.lib_.basic::ByteStream::UpstreamReference
  end

  Attributes_actor_ = -> cls, * a, & p do
    Fields_lib_[]::Attributes::Actor.via cls, p, a
  end

  Path_lib_ = Lazy_.call do
    Home_.lib_.basic::Pathname
  end

  Path_looks_relative_ = -> path do
    Home_.lib_.system.path_looks_relative path
  end

  Scanner_ = -> a do
    Common_::Scanner.via_array a
  end

  # ==

  Zerk_lib_ = Lazy_.call do
    Autoloader_.require_sidesystem :Zerk
  end

  Fields_lib_ = Lazy_.call do
    Autoloader_.require_sidesystem :Fields
  end

  # ==

  module Lib_

    sidesys, stdlib = Autoloader_.at(
      :build_require_sidesystem_proc,
      :build_require_stdlib_proc )

    # --

    Dev_tmpdir_path = -> do
      System[].defaults.dev_tmpdir_path
    end

    Ellipsify = -> s do
      Basic[]::String.ellipsify s
    end

    Entity = -> do
      Fields[]::Entity
    end

    Home_directory_pathname = -> do
      System[].environment.any_home_directory_pathname
    end

    List_scanner = -> x do
      Common_::Stream::Magnetics::MinimalStream_via[ x ]
    end

    Module_lib = -> do
      Basic[]::Module
    end

    Some_stderr = -> do
      System[].IO.some_stderr_IO
    end

    String_scanner = Common_.memoize do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib[].services
    end

    Tmpdir_stem = Common_.memoize do
      'tm-production-cache'.freeze
    end

    # --

    Basic = sidesys[ :Basic ]
    Brazen_NOUVEAU = sidesys[ :Brazen ]  # weird name for now for a while
    # = sidesys[ :Fields ]  # for [#sl-002]
    File_utils = stdlib[ :FileUtils ]
    Human = sidesys[ :Human ]
    Parse_lib = sidesys[ :Parse ]
    Pretty_print = stdlib[ :PP ]
    String_IO = stdlib[ :StringIO ]
    System_lib = sidesys[ :System ]
    TT = stdlib[ :Treetop ]
    # = sidesys[ :Zerk ]  # for [#sl-002]
  end

  # ==

  Autoloader_[ self, Common_::Without_extension[ __FILE__ ]]

  ACHIEVED_ = true
  # Brazen_ = ::Skylab::Brazen
  CONST_SEP_ = '::'.freeze
  DASH_ = '-'.freeze
  EMPTY_A_ = [].freeze
  EMPTY_P_ = -> {}
  EMPTY_S_ = ''.freeze
  # stowaway :Entity_, 'models-'
  FILE_SEPARATOR_ = ::File::SEPARATOR
  # stowaway :Kernel_, 'models-'
  NEWLINE_ = "\n".freeze
  NIL_ = nil
  NOTHING_ = nil
  SPACE_ = ' '.freeze
  Home_ = self
  UNABLE_ = false
  UNDERSCORE_ = '_'.freeze
end
