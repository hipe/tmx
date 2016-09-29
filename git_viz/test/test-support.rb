require 'skylab/git_viz'
require 'skylab/test_support'

module Skylab::GitViz::TestSupport

  class << self

    def [] tcc
      tcc.send :define_singleton_method, :use, Use_method___
      tcc.include InstanceMethods___
    end

    def at_ sym
      CONSTANTS___.lookup sym
    end

    def lib_
      @lib ||= Common_.produce_library_shell_via_library_and_app_modules(
        Lib_module___[], TS_ )
    end
  end  # >>

  TestSupport_ = ::Skylab::TestSupport

  extend TestSupport_::Quickie

  # -
    Use_method___ = -> do

      h = {}
      -> sym do
        ( h.fetch sym do
          x = TestSupport_.fancy_lookup sym, TS_
          h[ sym ] = x
        end )[ self ]
      end
    end.call
  # -

  module InstanceMethods___

    def debug!
      @do_debug = true ; nil
    end

    attr_reader :do_debug

    def debug_IO
      Home_.lib_.some_stderr_IO
    end

    def handle_event_selectively_
      event_log.handle_event_selectively
    end

    def cache_hash_for_stubbed_FS
      Universal_cache___[]
    end

    def cache_hash_for_stubbed_system
      Universal_cache___[]
    end

    def start_directory_noent_

      _em = expect_failed_by :start_directory_is_not_directory

      ev = _em.cached_event_value

      _sym = ev.to_event.terminal_channel_symbol

      :start_directory_does_not_exist == _sym or fail

      ev
    end
  end

  Common_ = ::Skylab::Common

  Universal_cache___ = Common_.memoize do
    {}
  end

  # ~ bundles (used with `use`)

  Double_Decker_Memoize = -> do

    memoize = -> sym, & p do

      define_singleton_method sym, & Common_.memoize( & p )

      define_method sym do

        self.class.send sym
      end

      NIL_
    end

    -> tcc do
      tcc.send :define_singleton_method, :memoize_, memoize
    end
  end.call

  module My_CLI_Expectations

    class << self

      def [] test_cls

        CLI_lib_[][ test_cls ]

        test_cls.include self

      end
    end  # >>

    def subject_CLI
      Home_::CLI
    end

    def get_invocation_strings_for_expect_stdout_stderr
      %w( gvz )
    end

    def the_list_of_all_visible_actions_for_CLI_expectations
      %w( ping hist-tree )
    end
  end

  Expect_Event = -> tcc do  # `tcc` = test context class

    tcc.include(
      Home_::Common_.test_support::Expect_Event::Test_Context_Instance_Methods )

    NIL_
  end

  Expect_Line = -> tcc do

    TestSupport_::Expect_line[ tcc ]
  end

  Memoizer_Methods = -> tcc do

    TestSupport_::Memoization_and_subject_sharing[ tcc ]
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

    def at_ sym
      TS_.at_ sym
    end
  end

  # ~ non-contant-ish support

  CLI_lib_ = -> do

    Home_.lib_.brazen.test_support.lib :CLI_support_expectations
  end

  # ~ constant-ishes

  Lib_module___ = Common_.memoize do

    module Lib____

      stdlib = Common_::Autoloader.build_require_stdlib_proc

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
        TS_.dir_path,
        'vcs-adapters/git/fixture-stories' )
    end
  end

  Home_ = ::Skylab::GitViz

  Home_::Autoloader_[ self, ::File.dirname( __FILE__ ) ]
  NIL_ = nil
  TS_ = self
end
