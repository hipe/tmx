module Skylab::SubTree

  module Library_

    stdlib = Autoloader_.method :require_stdlib

    o = {}
    o[ :FileUtils ] = stdlib
    o[ :Open3 ] = stdlib
    o[ :Shellwords ] = stdlib
    o[ :StringIO ] = stdlib
    o[ :Time ] = stdlib

    define_singleton_method :const_missing do | sym |
      const_set sym, o.fetch( sym )[ sym ]
    end
  end

  module Lib_

    sidesys = Autoloader_.build_require_sidesystem_proc

    Basic = sidesys[ :Basic ]
    Brazen = sidesys[ :Brazen ]
    Fields = sidesys[ :Fields ]
    Human = sidesys[ :Human ]

    _System_lib = sidesys[ :System ]

    System = -> do
      _System_lib[].services
    end

    _TS = sidesys[ :TestSupport ]

    Test_file_suffix_a = -> do
      [ _TS[].spec_rb ]
    end

    Test_dir_name_a = -> do
      _TS[].constant :TEST_DIR_NAME_A
    end

    INSTANCE = Common_.produce_library_shell_via_library_and_app_modules(
      self, Home_ )  # at the end

  end
end
