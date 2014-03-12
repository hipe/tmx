require_relative '../test-support'

module Skylab::GitViz::TestSupport::Test_Lib_::Mock_System

  ::Skylab::GitViz::TestSupport[ TS__ = self ]

  include CONSTANTS

  GitViz = GitViz

  extend TestSupport::Quickie

  GitViz::Autoloader_[ self, :boxxy ]  # find bundles sibling to this node

  GitViz::Autoloader_[ Fixtures = ::Module.new ]

end
