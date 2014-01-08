require_relative '../test-support'

module Skylab::GitViz::TestSupport::VCS_Adapters_::Git::System_Agent_

  Parent_TS__ = ::Skylab::GitViz::TestSupport::VCS_Adapters_::Git
  Parent_TS__[ TS__ = self ]

  include CONSTANTS

  GitViz = GitViz

  extend TestSupport::Quickie

  GitViz::TestSupport::Testable_Client::DSL[ self ]

  module InstanceMethods

    def with_system_agent & p
      @sa = testable_system_agent_class.new listener do |sa|
        sa.set_system_conduit mock_system_conduit
        p[ sa ]
      end ; nil
    end
  end

  testable_client_class :testable_system_agent_class do
    class Testable_System_Agent < GitViz::VCS_Adapters_::Git::System_Agent_
      public :get_any_nonzero_count_output_line_scanner_from_cmd
      self
    end
  end
end
