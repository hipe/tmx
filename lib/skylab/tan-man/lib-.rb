module Skylab::TanMan

  module Lib_

    memoize = Callback_.memoize

    sidesys, stdlib = Autoloader_.at :build_require_sidesystem_proc, :build_require_stdlib_proc

    Bsc__ = sidesys[ :Basic ]

    Basic_struct = -> do
      Bsc__[]::Struct
    end

    Constantize = -> x do
      Callback_::Name.lib.constantize x
    end

    Ellipsify = -> do
      Sg__[]::CLI.ellipsify
    end

    Entity = -> do
      Brazen_::Entity
    end

    Home_directory_pathname = -> do
      System[].environment.any_home_directory_pathname
    end

    HL__ = sidesys[ :Headless ]

    Module_lib = -> do
      Bsc__[]::Module
    end

    NLP_EN_methods = -> do
      HL__[].expression_agent.NLP_EN_methods
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
      Bsc__[]::String
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

    TTT = sidesys[ :TreetopTools ]

  end
end
