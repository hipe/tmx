module Skylab::Common::TestSupport

  module FixtureDirectories::Fftn_TS

    _this_is_normal = ::File.join FixtureDirectories.dir_path, 'fftn-ts'

    Autoloader_[ self, _this_is_normal ]

    stowaway :LEFT_LEG, 'left-leg/marsupial-foot--'
  end
end
