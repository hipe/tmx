module Skylab::TanMan

  module Lib_

    memoize = -> p { p_ = -> { x = p[] ; p_ = -> { x } ; x } ; -> { p_[] } }

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

    Entity = -> do
      Brazen_::Entity
    end

    Event = -> do
      Brazen_::Entity::Event
    end

    Event_builder = -> x do
      x.include Brazen_::Entity::Event::Builder_Methods ; nil
    end

    Home_directory_pathname = -> do
      HL__[]::System.system.any_home_directory_pathname
    end

    HL__ = sidesys[ :Headless ]

    Some_stderr = -> do
      HL__[]::System::IO.some_stderr_IO
    end

    String_scanner = memoize[ -> do
      require 'strscan' ; ::StringScanner
    end ]

    String_template = -> do
      BA__[]::String::Template
    end

    Tmpdir_stem = memoize[ -> { 'tina-man'.freeze } ]

    Two_streams = -> do
      HL__[]::System::IO.some_two_IOs
    end

    TT = memoize[ -> do
      require 'treetop' ; ::Treetop
    end ]

    TTT = sidesys[ :TreetopTools ]

  end
end
