module Skylab::Callback::TestSupport::Autoloader::Const_Reduce::Fixtures
  module One_Skorlab
    dir_pathname = Fixtures_.dir_pathname.join 'one-skorlab'
    define_singleton_method :dir_pathname do dir_pathname end
  end
end
