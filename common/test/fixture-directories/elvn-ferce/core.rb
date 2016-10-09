module Skylab::Common::TestSupport

  module FixtureDirectories::Elvn_Ferce

    Autoloader_[ self ]

    stowaway :TheGuest1, 'host-1-as-eponymous-file'

    stowaway :TheGuest2, 'host-2-as-corefile'

    stowaway :TheGuest3, 'host-3-as-hard-to-find-nsa-spy'
  end
end
