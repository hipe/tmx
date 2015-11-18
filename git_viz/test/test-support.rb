require 'skylab/git_viz'
require 'skylab/test_support'

module Skylab::GitViz::TestSupport

  class << self

    def at_ sym
      CONSTANTS___.lookup sym
    end

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        Lib_module___[], TS_ )
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ TS_ = self, ::File.dirname( __FILE__ ) ]

  extend TestSupport_::Quickie

  module ModuleMethods

    define_method :use, -> do
      h = {}
      -> sym do
        ( h.fetch sym do
          x = TestSupport_.fancy_lookup sym, TS_
          h[ sym ] = x
        end )[ self ]
      end
    end.call

    define_method :dangerous_memoize_, TestSupport_::DANGEROUS_MEMOIZE
  end

  module InstanceMethods

    def debug!
      @do_debug = true ; nil
    end

    attr_reader :do_debug

    def debug_IO
      Home_.lib_.some_stderr_IO
    end

    def cache_hash_for_stubbed_FS
      Universal_cache___[]
    end

    def cache_hash_for_stubbed_system
      Universal_cache___[]
    end
  end

  Callback_ = ::Skylab::Callback

  Universal_cache___ = Callback_.memoize do
    {}
  end

  # ~ bundles (used with `use`)

  Double_Decker_Memoize = -> do

    memoize = -> sym, & p do

      define_singleton_method sym, & Callback_.memoize( & p )

      define_method sym do

        self.class.send sym
      end

      NIL_
    end

    -> tcc do
      tcc.send :define_singleton_method, :memoize_, memoize
    end
  end.call

  module Expect_CLI

    class << self

      def [] test_cls

        Expect_CLI_lib_[][ test_cls ]

        test_cls.include self

      end
    end  # >>

    def subject_CLI
      Home_::CLI
    end

    def get_invocation_strings_for_expect_stdout_stderr
      %w( gvz )
    end

    def the_list_of_all_visible_actions_for_expect_CLI
      %w( ping hist-tree )
    end
  end

  Expect_Event = -> tcc do  # `tcc` = test context class

    tcc.include(
      Home_::Callback_.test_support::Expect_event::Test_Context_Instance_Methods )

    NIL_
  end

  Expect_Line = -> tcc do

    TestSupport_::Expect_line[ tcc ]
  end

  Stubbed_filesystem = -> tcc do

    Home_.lib_.system_lib::Doubles::Stubbed_Filesystem.enhance_client_class tcc
  end

  Stubbed_system = -> tcc do

    Home_.lib_.system_lib::Doubles::Stubbed_System.enhance_client_class tcc
  end

  module Reactive_Model_Support

    def self.[] tcc
      Expect_Event[ tcc ]
      tcc.include self
    end

    def subject_API  # #hook-out for "expect event"
      Home_::API
    end

    def black_and_white_expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end

    def at_ sym
      TS_.at_ sym
    end
  end

  # ~ non-contant-ish support

  Expect_CLI_lib_ = -> do

    Home_.lib_.brazen.test_support.CLI::Expect_CLI
  end

  # ~ constant-ishes

  Lib_module___ = Callback_.memoize do

    module Lib____

      stdlib = Callback_::Autoloader.build_require_stdlib_proc

      String_IO = stdlib[ :StringIO ]

      self
    end
  end

  class CONSTANTS___ < TestSupport_::Lazy_Constants

    define_method :GIT_STORY_03_PATHS_ do

      ::File.join(
        lookup( :GIT_FIXTURE_STORIES_ ),
        '03-funky/paths.list' )
    end

    define_method :GIT_STORY_03_COMMANDS_ do

      ::File.join(
         lookup( :GIT_FIXTURE_STORIES_ ),
        '03-funky/commands.ogdl' )
    end

    define_method :GIT_STORY_04_PATHS_ do

      ::File.join(
        lookup( :GIT_FIXTURE_STORIES_ ),
        '04-jaunty-experiment/paths.list' )
    end

    define_method :GIT_STORY_04_COMMANDS_ do

      ::File.join(
        lookup( :GIT_FIXTURE_STORIES_ ),
        '04-jaunty-experiment/commands.ogdl' )
    end

    define_method :GIT_FIXTURE_STORIES_ do

      ::File.join(
        TS_.dir_pathname.to_path,
        'vcs-adapters/git/fixture-stories' )
    end
  end

  Home_ = ::Skylab::GitViz
  NIL_ = nil
end
