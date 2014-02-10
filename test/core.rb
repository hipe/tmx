module Skylab::Test

  require_relative '../lib/skylab/callback/core'

  Callback_ = ::Skylab::Callback
  Autoloader_ = Callback_::Autoloader

  module Lib_  # :+[#ss-001]

    sidesys, stdlib = Autoloader_.at :build_require_sidesystem_proc,
      :build_require_stdlib_proc

    Basic__ = sidesys[ :Basic ]

    Basic_Mutex = -> do
      Basic__[]::Mutex
    end

    Basic_Tree = -> do
      Basic__[]::Tree
    end

    CLI_curriable_stylize_proc = -> do
      Headless__[]::CLI::Pen::FUN::Stylify
    end

    CLI_option = -> do  # e.g ::on, Merger, Parser
      Headless__[]::CLI::Option
    end

    CLI_table = -> * a do
      Face__[]::CLI::Table.new( a ).execute
    end

    EN_calculate = -> p do
      Headless__[]::NLP::EN.calculate( & p )
    end

    Face__ = sidesys[ :Face ]

    Headless__ = sidesys[ :Headless ]

    Heavy_plugin = -> do
      Face__[]::Plugin
    end

    MetaHell__ = sidesys[ :MetaHell ]

    Oxford_and = -> a do
      Callback_::Oxford_and[ a ]
    end

    Parse_field = -> do
      MetaHell__[]::FUN::Parse::Field_
    end

    Parse_series = -> do
      MetaHell__[]::FUN.parse_series
    end

    Pretty_path_proc = -> do
      Headless__[]::CLI::PathTools::FUN::Pretty_path
    end

    Puff_constant = -> do
      MetaHell__[]::FUN::Puff_constant_
    end

    Reparenthesize = -> p, msg do
      Face__[]::CLI.reparenthesize[ p, msg ]
    end

    Spec_rb = -> do
      TestSupport__[]::FUN::Spec_rb[]
    end

    TestSupport__ = sidesys[ :TestSupport ]

    Set = stdlib[ :Set ]
  end

  EMPTY_A_ = [].freeze

  Stderr_ = -> { $stderr }  # resources should not be accessed as contants
                            # or globals from within application code
  Test = self

  UNIVERSAL_TEST_DIR_RELPATH_ = 'test'.freeze

  Autoloader_[ self, ::Pathname.new( ::File.dirname __FILE__ ) ]

  stowaway :Benchmark, -> { TestSupport::Benchmark }

end
