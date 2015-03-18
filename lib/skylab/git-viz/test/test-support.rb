require_relative '../core'

module Skylab::GitViz::TestSupport

  GitViz_ = ::Skylab::GitViz

  Callback_ = GitViz_::Callback_

  class << self

    def lib_
      @lib ||= Callback_.produce_library_shell_via_library_and_app_modules(
        Lib_module___[], TS_ )
    end

    define_method :universal_cache_hash_, ( Callback_.memoize do
      {}
    end )
  end  # >>

  TestSupport_ = GitViz_.lib_.test_support

  TestSupport_::Regret[ TS_ = self ]

  extend TestSupport_::Quickie

  module ModuleMethods

    def use sym

      const_i = Callback_::Name.via_variegated_symbol( sym ).as_const
      mod = nearest_test_node

      begin
        if mod.const_defined? const_i, false
          found_callable = mod.const_get const_i
          break
        end
        mod_ = mod.parent_anchor_module
        if ! mod_
          found_callable = GitViz_::Test_Lib_.const_get const_i, false
          break
        end
        mod = mod_
        redo
      end while nil

      found_callable[ self ]
      NIL_
    end
  end

  module InstanceMethods

    def debug!
      @do_debug = true ; nil
    end

    attr_reader :do_debug

    def debug_IO
      GitViz_.lib_.some_stderr_IO
    end

    def cache_hash_for_mock_FS
      TS_.universal_cache_hash_
    end

    def cache_hash_for_mock_system
      TS_.universal_cache_hash_
    end

    def listener_x  # assume "expect event" ..

      # the event receiver in whatever form is current

      handle_event_selectively
    end
  end

  # ~ longer short constants (the longest of which we might call "stowaways")

  # ~ lib

  Lib_module___ = Callback_.memoize do

    module Lib____

      stdlib = Callback_::Autoloader.build_require_stdlib_proc

      String_IO = stdlib[ :StringIO ]

      self
    end
  end

  Expect_Event = -> test_mod do  # generated from `expect_event`

    test_mod.include(
      GitViz_::Callback_.test_support::Expect_event::Test_Context_Instance_Methods )

    nil
  end

  Expect_Line = -> test_mod do

    TestSupport_::Expect_line[ test_mod ]
  end

  module Messages
    PATH_IS_FILE = "path is file, must have directory".freeze
  end

  GIT_FIXTURE_STORIES_ = ::File.join TS_.dir_pathname.to_path,
    'vcs-adapters/git/fixture-stories'

  GIT_STORY_03_PATHS_ = ::File.join GIT_FIXTURE_STORIES_,
    '03-funky/paths.list'

  GIT_STORY_03_COMMANDS_ = ::File.join GIT_FIXTURE_STORIES_,
    '03-funky/commands.ogdl'

  module Testable_Client  # read [#015] the testable client narrative intro.

    DSL = -> mod do
      mod.extend Test_Node_Module_Methods_ ; nil
    end

    module Test_Node_Module_Methods_
    private
      def testable_client_class i, & p
        p_ = -> do  # #storypoint-20
          r = p[] ; p_ = -> { r } ; r
        end
        instance_methods_module.module_exec do
          define_method i do
            p_[]
          end
        end ; nil
      end
    end
  end

  Autoloader_ = GitViz_::Autoloader_

  module VCS_Adapters
    module Git
      Autoloader_[ Fixtures = ::Module.new ]

      Autoloader_[ self ]
    end
    Autoloader_[ self ]
  end

  # ~ short constants

  NIL_ = nil

  # ~ any re-assignments of above to propagate to child test nodes

  module Constants
    Callback_ = Callback_
    GitViz_ = GitViz_
    GIT_FIXTURE_STORIES_ = GIT_FIXTURE_STORIES_
    GIT_STORY_03_COMMANDS_ = GIT_STORY_03_COMMANDS_
    GIT_STORY_03_PATHS_ = GIT_STORY_03_PATHS_
    NIL_ = NIL_
    TestSupport_ = TestSupport_
    Top_TS_ = TS_
  end

  # ~ set it up so we peek into the FS to autoload usees

  Autoloader_[ self, :boxxy, GitViz_.dir_pathname.join( 'test' ).to_path ]

end
