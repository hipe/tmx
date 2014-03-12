module Skylab::Callback::TestSupport
  module Autoloader::Fixtures::Elvn_Ferce::TerstSerppert::CIL

    _dpn = Autoloader::Fixtures::Elvn_Ferce.dir_pathname.join 'terst/cil'
    Autoloader_[ self, _dpn ]

    stowaway :Client, 'xxx/yyy'
  end
end
