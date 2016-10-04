module Skylab::Common::TestSupport::FixtureTree

  module Tre_Skorlab

    path = ::File.join FixtureTree_.dir_path, 'tre-skorlab'

    define_singleton_method :dir_path do
      path
    end
  end
end
