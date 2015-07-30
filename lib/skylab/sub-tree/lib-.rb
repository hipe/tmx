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

    _HL = sidesys[ :Headless ]

    CLI_lib = -> do
      _HL[]::CLI
    end

    EN_add_methods = -> * i_a do
      _HL[].expression_agent.NLP_EN_methods.call_via_arglist i_a
    end

    Strange_proc = -> do
      Basic[]::String.via_mixed.to_proc
    end

    _Hu = sidesys[ :Human ]

    Summarize_time = -> x do
      _Hu[]::Summarize::Time[ x ]
    end

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

    Tree = -> do
      Basic[]::Tree
    end

    INSTANCE = Callback_.produce_library_shell_via_library_and_app_modules(
      self, Home_ )  # at the end

  end
end
