require_relative '../test-support'

module Skylab::MetaHell::TestSupport::BasicFields

  ::Skylab::MetaHell::TestSupport[ Basic_Fields_TestSupport = self ]

  include CONSTANTS

  MetaHell = MetaHell

  Sandboxer = TestSupport::Sandbox::Spawner.new

end
