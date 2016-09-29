module Skylab::Common::TestSupport
  module Autoloader::Fixtures::Elvn_Ferce::TerstSerppert::CIL

    _dpn = Autoloader::Fixtures::Elvn_Ferce.dir_pathname.join 'terst/cil'
    Autoloader_[ self, _dpn.to_path ]

    stowaway :Client, 'xxx/yyy'
  end
end
