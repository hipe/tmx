require_relative '../test-support'

module Skylab::GitViz::TestSupport::Test_Lib_

  ::Skylab::GitViz::TestSupport[ self ]

  module Mock_System
    ::Skylab::Callback::Autoloader[ self, :boxxy ]  # we need the
      # "test node extensions" implementation to see e.g the 'server_expect'
      # extension. this became necessary with the new autoloader rewrite and
      # we are not sure why, but it's probably for the better.
  end
end
