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
      GitViz_::VCS_Adapters_::Git::Front.new_via_system_conduit(
        mock_system_conduit, & listener_x )
    end

    def expect_result_for_failure  # #hook-out
      @result.should eql false
    end

    def black_and_white_expression_agent_for_expect_event
      GitViz_.lib_.brazen::API.expression_agent_instance
    end
  end

  # ~

  Commit_Support = -> test_context_mod do

    TS_::Model_Support::Commit_support[ test_context_mod ]
  end

  # ~

  Autoloader_ = Callback_::Autoloader
  ACHIEVED_ = true
  Callback_ = Callback_
  GENERAL_ERROR_ = 128
  NIL_ = nil

  fixture_stories = ::File.join( TS_.dir_pathname.to_path, 'fixture-stories' )

  STORY_02_PATHS_ = ::File.join fixture_stories, '02-path-of-interest/paths.list'
  STORY_02_COMMANDS_ = ::File.join fixture_stories, '02-path-of-interest/commands.ogdl'

  STORY_03_PATHS_ = ::File.join fixture_stories, '03-funky/paths.list'
  STORY_03_COMMANDS_ = ::File.join fixture_stories, '03-funky/commands.ogdl'

end
