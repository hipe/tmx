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

    def front
      @front ||= build_front
    end

    def build_front
      front_class.new GitViz_::VCS_Adapters_::Git, listener_x do |f|
        f.set_system_conduit system_conduit
      end
    end

    def system_conduit
    end

    def front_class
      _VCS_adapter_module::Front
    end

    def _VCS_const i
      _VCS_adapter_module::Front.class  # always ensure this is loaded first
      _VCS_adapter_module.const_get i, false
    end

    def expect_result_for_failure  # #hook-out
      @result.should eql false
    end

    def execute_this_cmd( *a )
      system_agent.execute_this_cmd_a a
    end

    def _VCS_adapter_module
      GitViz_::VCS_Adapters_::Git
    end

    def black_and_white_expression_agent_for_expect_event
      GitViz_.lib_.brazen::API.expression_agent_instance
    end
  end
end
