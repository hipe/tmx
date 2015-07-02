require_relative '../test-support'

module Skylab::GitViz::TestSupport::Test_Lib::Mock_System

  ::Skylab::GitViz::TestSupport[ TS_ = self ]

  include Constants

  Home_ = Home_

  extend TestSupport_::Quickie

  Home_::Autoloader_[ self, :boxxy ]  # find bundles sibling to this node

  Home_::Autoloader_[ Fixtures = ::Module.new ]

end
