module Skylab::TanMan

  module Lib_

    memoize = Callback_.memoize

    sidesys = Autoloader_.build_require_sidesystem_proc

    BA__ = sidesys[ :Basic ]

    Basic_struct = -> do
      BA__[]::Struct
    end

    Constantize = -> x do
      Callback_::Name.lib.constantize x
    end

    Dev_tmpdir_pathname = -> do
      HL__[]::System.defaults.dev_tmpdir_pathname
    end

    EN_fun = -> do
      HL__[]::SubClient::EN_FUN
    end

    Ellipsify = -> do
      Snag__[]::CLI.ellipsify
    end

    Entity = -> do
      Brazen_::Entity
    end

    Home_directory_pathname = -> do
      HL__[]::System.system.any_home_directory_pathname
    end

    HL__ = sidesys[ :Headless ]

    Snag__ = sidesys[ :Snag ]

    Some_stderr = -> do
      HL__[]::System::IO.some_stderr_IO
    end

    String_IO = memoize[ -> do
      require 'stringio' ; ::StringIO
    end ]

    String_scanner = memoize[ -> do
      require 'strscan' ; ::StringScanner
    end ]

    String_template = -> do
      BA__[]::String::Template
    end

    Tmpdir_stem = memoize[ -> { 'tina-man'.freeze } ]

    TT = memoize[ -> do
      require 'treetop' ; ::Treetop
    end ]

    TTT = sidesys[ :TreetopTools ]

  end
end
