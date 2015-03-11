require_relative '../test-support'

module Skylab::GitViz::TestSupport::Models

  ::Skylab::GitViz::TestSupport[ TS_ = self ]

  include Constants

  GitViz_ = GitViz_

  extend TestSupport_::Quickie

  module InstanceMethods

    def subject_API  # #hook-out for "expect event"
      GitViz_::API
    end

    def black_and_white_expression_agent_for_expect_event
      GitViz_.lib_.brazen::API.expression_agent_instance
    end

    def fixtures_module_
      GitViz_::TestSupport::VCS_Adapters::Git::Fixtures
    end
  end
end
