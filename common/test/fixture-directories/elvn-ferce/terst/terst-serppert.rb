module Skylab::Common::TestSupport
  module FixtureDirectories::Elvn_Ferce
    module TerstSerppert
      # we "simuate" what these test nodes
      _dpn = FixtureDirectories::Elvn_Ferce.dir_pathname.join 'terst'
      Autoloader_[ self, _dpn.to_path ]

      stowaway :CIL, 'cil/terst-serppert'
    end
  end
end
