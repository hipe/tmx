module Skylab::Common::TestSupport

  module FixtureDirectories::Twlv_DLI::Glient

    path = ::File.join TS_.dir_path, 'xy', 'zzy'

    define_singleton_method :dir_path do
      path
    end
  end
end
