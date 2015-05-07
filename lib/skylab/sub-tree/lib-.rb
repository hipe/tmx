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

    CLI_table = -> * x_a do
      FA___[]::CLI::Table.call_via_iambic x_a
    end

    EN_add_methods = -> * i_a do
      HL__[].expression_agent.NLP_EN_methods.call_via_arglist i_a
    end

    FA___ = sidesys[ :Face ]

    HL__ = sidesys[ :Headless ]

    IT___ = sidesys[ :InformationTactics ]

    MH___ = sidesys[ :MetaHell ]

    Strange_proc = -> do
      MH___[].strange.to_proc
    end

    Summarize_time = -> x do
      IT___[]::Summarize::Time[ x ]
    end

    System = -> do
      System_lib___[].services
    end

    System_lib___ = sidesys[ :System ]

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
      self, SubTree_ )  # at the end

  end
end
