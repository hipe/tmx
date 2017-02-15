module Skylab::TanMan

  module Lib_

    sidesys, stdlib = Autoloader_.at :build_require_sidesystem_proc, :build_require_stdlib_proc

    Basic = sidesys[ :Basic ]

    # = sidesys[ :Brazen ]  # for [sl]

    Dev_tmpdir_path = -> do
      System[].defaults.dev_tmpdir_path
    end

    Ellipsify = -> s do
      Basic[]::String.ellipsify s
    end

    Entity = -> do
      Fields[]::Entity
    end

    Fields = sidesys[ :Fields ]

    File_utils = stdlib[ :FileUtils ]

    Home_directory_pathname = -> do
      System[].environment.any_home_directory_pathname
    end

    Human = sidesys[ :Human ]

    List_scanner = -> x do
      Common_::Stream::Magnetics::MinimalStream_via[ x ]
    end

    Module_lib = -> do
      Basic[]::Module
    end

    Parse_lib = sidesys[ :Parse ]

    Pretty_print = stdlib[ :PP ]

    Some_stderr = -> do
      System[].IO.some_stderr_IO
    end

    String_IO = stdlib[ :StringIO ]

    String_scanner = Common_.memoize do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib___[].services
    end

    System_lib___ = sidesys[ :System ]

    Tmpdir_stem = Common_.memoize do
      'tm-production-cache'.freeze
    end

    TT = stdlib[ :Treetop ]

    # = sidesys[ :Zerk ]  # for [sl]

    INSTANCE = Common_.produce_library_shell_via_library_and_app_modules(
      self, Home_ )
  end

  LIB_ = Lib_::INSTANCE

end
