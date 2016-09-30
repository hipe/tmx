module Skylab::Common::TestSupport::FixtureTree

  module One_Skorlab

    path = ::File.join FixtureTree_.dir_path, 'one-skorlab'

    define_singleton_method :dir_path do
      path
    end
  end
end
