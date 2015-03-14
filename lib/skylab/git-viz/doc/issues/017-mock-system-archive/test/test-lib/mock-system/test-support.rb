require_relative '../test-support'

module Skylab::GitViz::TestSupport::Test_Lib::Mock_System

  ::Skylab::GitViz::TestSupport[ TS_ = self ]

  include Constants

  GitViz_ = GitViz_

  extend TestSupport_::Quickie

  GitViz_::Autoloader_[ self, :boxxy ]  # find bundles sibling to this node

  GitViz_::Autoloader_[ Fixtures = ::Module.new ]

end
