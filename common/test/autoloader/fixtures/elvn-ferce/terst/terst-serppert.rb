module Skylab::Common::TestSupport
  module Autoloader::Fixtures::Elvn_Ferce
    module TerstSerppert
      # we "simuate" what these test nodes
      _dpn = Autoloader::Fixtures::Elvn_Ferce.dir_pathname.join 'terst'
      Autoloader_[ self, _dpn.to_path ]

      stowaway :CIL, 'cil/terst-serppert'
    end
  end
end