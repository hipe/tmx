module Skylab::Common::TestSupport::FixtureTree
  module One_Skorlab
    dir_pathname = FixtureTree_.dir_pathname.join 'one-skorlab'
    define_singleton_method :dir_pathname do dir_pathname end
  end
end
