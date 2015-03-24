require_relative '../../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters

  ::Skylab::GitViz::TestSupport[ self ]

end

module Skylab::GitViz::TestSupport::VCS_Adapters::Git

  ::Skylab::GitViz::TestSupport::VCS_Adapters[ TS_ = self ]

  include Constants

  GitViz_ = GitViz_

  extend TestSupport_::Quickie

  module InstanceMethods

    def front_
      @front ||= __build_front
    end

    def __build_front
      subject_VCS::Front.new_via_system_conduit(
        mock_system_conduit, & listener_x )
    end

    def subject_VCS
      GitViz_::VCS_Adapters_::Git
    end

    def expect_result_for_failure  # #hook-out
      @result.should eql false
    end

    def black_and_white_expression_agent_for_expect_event
      GitViz_.lib_.brazen::API.expression_agent_instance
    end
  end

  # ~

  Bundle_Support = -> tcm do

    tcm.include InstanceMethods  # for when nodes from outside our graph come in

    Repository_Support[ tcm ]

    tcm.send :define_method, :bundle_against_ do | abs |

      init_respository_via_pathname_ mock_pathname abs

      x = subject_VCS::Models_::Bundle.build_via_path_and_repo(

        @repository.relative_path_of_interest,
        @repository,
        MOCK_RSX___,
        & handle_event_selectively )

      if x
        @bundle = x
      else
        @result = x
      end

      NIL_
    end

    NIL_
  end

  MOCK_RSX___ = class Mock_Resources___

    def stderr
      Top_TS_::Expect_CLI.mock_stderr_instance
    end

    self
  end.new

  Commit_Support = -> test_context_mod do

    TS_::Model_Support::Commit_support[ test_context_mod ]
  end

  Repository_Support = -> tcm do

    Top_TS_::Expect_Event[ tcm ]
    GitViz_::Test_Lib_::Mock_FS[ tcm ]
    GitViz_::Test_Lib_::Mock_System[ tcm ]

    tcm.send :define_method, :init_respository_via_pathname_ do | s |
      x = front_.new_repository_via_pathname mock_pathname s
      if x
        @result = nil
        @repository = x
      else
        @result = x
        @repository = x
      end
      NIL_
    end
    NIL_
  end

  # ~

  Autoloader_ = Callback_::Autoloader
  ACHIEVED_ = true
  Callback_ = Callback_
  DASH_ = GitViz_::DASH_
  DOT_ = GitViz_::DOT_
  EMPTY_S_ = GitViz_::EMPTY_S_
  GENERAL_ERROR_ = 128
  NIL_ = nil
  UNDERSCORE_ = GitViz_::UNDERSCORE_

  SHORT_SHA_LENGTH_ = 7

  STORY_02_PATHS_ = ::File.join GIT_FIXTURE_STORIES_, '02-path-of-interest/paths.list'
  STORY_02_COMMANDS_ = ::File.join GIT_FIXTURE_STORIES_, '02-path-of-interest/commands.ogdl'

  STORY_03_PATHS_ = GIT_STORY_03_PATHS_
  STORY_03_COMMANDS_ = GIT_STORY_03_COMMANDS_


  Top_TS_ = Top_TS_

end
