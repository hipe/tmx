module Skylab::TanMan

  module Lib_

    memoize = Callback_.memoize

    sidesys, stdlib = Autoloader_.at :build_require_sidesystem_proc, :build_require_stdlib_proc

    Basic = sidesys[ :Basic ]

    Basic_struct = -> * i_a, & p do
      Basic[]::Struct.make_via_arglist i_a, & p
    end

    Constantize = -> x do
      Callback_::Name.lib.constantize x
    end

    Dev_tmpdir_pathname = -> do
      System[].defaults.dev_tmpdir_pathname
    end

    Dry_stub = -> do
      HL__[]::IO.dry_stub_instance
    end

    Ellipsify = -> s do
      Basic[]::String.ellipsify s
    end

    Entity = -> do
      Brazen_::Entity
    end

    File_utils = memoize.call do
      require 'fileutils' ; ::FileUtils
    end

    Home_directory_pathname = -> do
      System[].environment.any_home_directory_pathname
    end

    HL__ = sidesys[ :Headless ]

    List_scanner = -> x do
      Callback_::Scn.try_convert x
    end

    Module_lib = -> do
      Basic[]::Module
    end

    MH__ = sidesys[ :MetaHell ]

    NLP_EN_methods = -> do
      HL__[].expression_agent.NLP_EN_methods
    end

    Parameter = -> do
      HL__[]::Parameter
    end

    Parse_lib = -> do
      MH__[]::Parse
    end

    Path_tools = -> do
      HL__[].system.filesystem.path_tools
    end

    Pretty_print = stdlib[ :PP ]

    Proxy_lib = -> do
      Callback_::Proxy
    end

    Sg__ = sidesys[ :Snag ]

    Some_stderr = -> do
      System[].IO.some_stderr_IO
    end

    String_IO = memoize[ -> do
      require 'stringio' ; ::StringIO
    end ]

    String_lib = -> do
      Basic[]::String
    end

    String_scanner = memoize[ -> do
      require 'strscan' ; ::StringScanner
    end ]

    System = -> do
      HL__[].system
    end

    Tmpdir_stem = memoize[ -> { 'tina-man'.freeze } ]

    TT = memoize[ -> do
      require 'treetop' ; ::Treetop
    end ]

    INSTANCE = Callback_.produce_library_shell_via_library_and_app_modules(
      self, TanMan_ )
  end

  LIB_ = Lib_::INSTANCE

end
