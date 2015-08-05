module Skylab::TanMan

  module Lib_

    sidesys, stdlib = Autoloader_.at :build_require_sidesystem_proc, :build_require_stdlib_proc

    Basic = sidesys[ :Basic ]

    Basic_struct = -> * i_a, & p do
      Basic[]::Struct.make_via_arglist i_a, & p
    end

    # = sidesys[ :Brazen ]  # for [sl]

    Constantize = -> x do
      Callback_::Name.lib.constantize x
    end

    Dev_tmpdir_pathname = -> do
      System[].defaults.dev_tmpdir_pathname
    end

    Ellipsify = -> s do
      Basic[]::String.ellipsify s
    end

    Entity = -> do
      Brazen_::Entity
    end

    File_utils = stdlib[ :FileUtils ]

    Home_directory_pathname = -> do
      System[].environment.any_home_directory_pathname
    end

    List_scanner = -> x do
      Callback_::Scn.try_convert x
    end

    Module_lib = -> do
      Basic[]::Module
    end

    ___Fields = sidesys[ :Fields ]

    Parameter = -> do  # this is used in so many places, we defy convention
      ___Fields[]::Parameter
    end

    Parse_lib = sidesys[ :Parse ]

    Path_tools = -> do
      System[].filesystem.path_tools
    end

    Pretty_print = stdlib[ :PP ]

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Some_stderr = -> do
      System[].IO.some_stderr_IO
    end

    String_IO = stdlib[ :StringIO ]

    String_lib = -> do
      Basic[]::String
    end

    String_scanner = Callback_.memoize do
      require 'strscan'
      ::StringScanner
    end

    System = -> do
      System_lib___[].services
    end

    System_lib___ = sidesys[ :System ]

    Tmpdir_stem = Callback_.memoize do
      'tina-man'.freeze
    end

    TT = stdlib[ :Treetop ]

    INSTANCE = Callback_.produce_library_shell_via_library_and_app_modules(
      self, Home_ )
  end

  LIB_ = Lib_::INSTANCE

end
