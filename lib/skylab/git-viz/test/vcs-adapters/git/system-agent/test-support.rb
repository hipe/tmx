require_relative '../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters::Git::System_Agent

  Parent_TS__ = ::Skylab::GitViz::TestSupport::VCS_Adapters::Git
  Parent_TS__[ TS__ = self ]

  include Constants

  GitViz_ = GitViz_

  extend TestSupport_::Quickie

  GitViz_::TestSupport::Testable_Client::DSL[ self ]

  module InstanceMethods

    def with_system_agent & p
      @sa = testable_system_agent_class.new listener do |sa|
        sa.set_system_conduit mock_system_conduit
        p[ sa ]
      end ; nil
    end
  end

  testable_client_class :testable_system_agent_class do
    class Testable_System_Agent < GitViz_::VCS_Adapters_::Git::System_Agent_
      public :get_any_nonzero_count_output_line_stream_from_cmd
      self
    end
  end
end
