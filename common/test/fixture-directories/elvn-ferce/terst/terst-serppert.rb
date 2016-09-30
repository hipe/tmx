module Skylab::Common::TestSupport

  module FixtureDirectories::Elvn_Ferce

    module TerstSerppert

      # we "simuate" what these test nodes

      _path = ::File.join FixtureDirectories::Elvn_Ferce.dir_path, 'terst'

      Autoloader_[ self, _path ]

      stowaway :CIL, 'cil/terst-serppert'
    end
  end
end
