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

  TestSupport_::Quickie.
    enhance_test_support_module_with_the_method_called_describe self

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

      _em = want_failed_by :start_directory_is_not_directory

      ev = _em.cached_event_value

      _sym = ev.to_event.terminal_channel_symbol

      :start_directory_does_not_exist == _sym or fail

      ev
    end

    def subject_API_value_of_failure
      FALSE
    end
  end

  Common_ = ::Skylab::Common

  Universal_cache___ = Common_::Lazy_.call do
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

  module My_CLI

    class << self

      def [] test_cls

        CLI_lib_[][ test_cls ]

        test_cls.include self

      end
    end  # >>

    def subject_CLI
      Home_::CLI
    end

    def get_invocation_strings_for_want_stdout_stderr
      %w( gvz )
    end

    def the_list_of_all_visible_actions_for_CLI_expectations
      %w( ping hist-tree )
    end
  end

  Want_Event = -> tcc do  # `tcc` = test context class

    tcc.include(
      Home_::Common_.test_support::Want_Emission::Test_Context_Instance_Methods )

    NIL_
  end

  Want_Line = -> tcc do

    TestSupport_::Want_line[ tcc ]
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

  module Reactive_Model

    def self.[] tcc
      Want_Event[ tcc ]
      tcc.include self
    end

    def subject_API  # #hook-out for "want event"
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

      stdlib = Autoloader_.build_require_stdlib_proc

      String_IO = stdlib[ :StringIO ]

      self
    end
  end

  class CONSTANTS___ < TestSupport_::Lazy_Constants

    def GIT_STORY_03_PATHS_
      ::File.join _git_fixture_stories, '03-funky/paths.list'
    end

    def GIT_STORY_03_COMMANDS_
      ::File.join _git_fixture_stories, '03-funky/commands.ogdl'
    end

    def GIT_STORY_04_PATHS_
      ::File.join _git_fixture_stories, '04-jaunty-experiment/paths.list'
    end

    def GIT_STORY_04_COMMANDS_
      ::File.join _git_fixture_stories, '04-jaunty-experiment/commands.ogdl'
    end

    def _git_fixture_stories
      lookup :GIT_FIXTURE_STORIES_
    end

    def GIT_FIXTURE_STORIES_
      ::File.join TS_.dir_path, 'fixture-stories-for-git'
    end
  end

  Home_ = ::Skylab::GitViz
  Autoloader_ = Home_::Autoloader_

  Autoloader_[ self, ::File.dirname( __FILE__ ) ]

  NIL_ = nil
  FALSE = false  # #open [#sli-116.C]
  TS_ = self
end
