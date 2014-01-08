require_relative '../test-support'

module Skylab::GitViz::TestSupport::Mock_System_Tests

  ::Skylab::GitViz::TestSupport[ TS__ = self ]

  include CONSTANTS

  Mock_System_Parent_Module__ = GitViz::TestSupport

  extend TestSupport::Quickie

end
