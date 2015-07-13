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

    CLI_lib = -> do
      HL__[]::CLI
    end

    EN_add_methods = -> * i_a do
      HL__[].expression_agent.NLP_EN_methods.call_via_arglist i_a
    end

    FA___ = sidesys[ :Face ]

    Hu___ = sidesys[ :Human ]

    HL__ = sidesys[ :Headless ]

    Strange_proc = -> do
      Basic[]::String.via_mixed.to_proc
    end

    Summarize_time = -> x do
      Hu___[]::Summarize::Time[ x ]
    end

    _System_lib = sidesys[ :System ]

    System = -> do
      _System_lib[].services
    end

    Test_file_suffix_a = -> do
      [ TS___[].spec_rb ]
    end

    Test_dir_name_a = -> do
      TS___[].constant :TEST_DIR_NAME_A
    end

    Tree = -> do
      Basic[]::Tree
    end

    TS___ = sidesys[ :TestSupport ]

    INSTANCE = Callback_.produce_library_shell_via_library_and_app_modules(
      self, Home_ )  # at the end

  end
end
