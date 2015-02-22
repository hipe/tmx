module Skylab::Test

  require_relative '../lib/skylab/callback/core'

  Callback_ = ::Skylab::Callback
  Autoloader_ = Callback_::Autoloader

  module Lib_  # :+[#ss-001]

    sidesys, stdlib = Autoloader_.at :build_require_sidesystem_proc,
      :build_require_stdlib_proc

    Bsc__ = sidesys[ :Basic ]

    Basic_Mutex = -> do
      Bsc__[]::Mutex
    end

    Basic_Tree = -> do
      Bsc__[]::Tree
    end

    CLI_lib = -> do
      HL__[]::CLI
    end

    CLI_table = -> * x_a do
      Face__[]::CLI::Table.via_iambic x_a
    end

    EN_calculate = -> & p do
      HL__[].expression_agent.NLP_EN_agent.calculate( & p )
    end

    Face__ = sidesys[ :Face ]

    HL__ = sidesys[ :Headless ]

    Heavy_plugin = -> do
      Face__[]::Plugin
    end

    MH__ = sidesys[ :MetaHell ]

    Oxford_and = -> a do
      Callback_::Oxford_and[ a ]
    end

    Parse_lib = -> do
      MH__[]::Parse
    end

    Pretty_path_proc = -> do
      HL__[].system.filesystem.path_tools.pretty_path
    end

    Reparenthesize = -> p, msg do
      Face__[]::CLI.reparenthesize[ p, msg ]
    end

    Set = stdlib[ :Set ]

    Spec_rb = -> do
      TestSupport__[].spec_rb
    end

    TestSupport__ = sidesys[ :TestSupport ]

    Touch_const = -> do
      MH__[].touch_const
    end
  end

  EMPTY_A_ = [].freeze

  Stderr_ = -> { $stderr }  # resources should not be accessed as contants
                            # or globals from within application code
  Test_ = self

  UNIVERSAL_TEST_DIR_RELPATH_ = 'test'.freeze

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :Benchmark, -> { TestSupport::Benchmark }

end
