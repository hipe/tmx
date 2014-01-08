require_relative '../../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters_

  ::Skylab::GitViz::TestSupport[ self ]

end

module Skylab::GitViz::TestSupport::VCS_Adapters_::Git

  ::Skylab::GitViz::TestSupport::VCS_Adapters_[ TS__ = self ]

  include CONSTANTS

  GitViz = GitViz ; MetaHell = MetaHell

  extend TestSupport::Quickie

  module InstanceMethods

    def front
      @front ||= build_front
    end

    def build_front
      _VCS_adapter_module::Front.new GitViz::VCS_Adapters_::Git, listener
    end

    def expect_result_for_failure  # #hook-out
      @result.should eql false
    end

    def execute_this_cmd( *a )
      system_agent.execute_this_cmd_a a
    end

    def _VCS_adapter_module
      GitViz::VCS_Adapters_::Git
    end
  end
end
