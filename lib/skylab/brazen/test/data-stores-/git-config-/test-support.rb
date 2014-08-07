require_relative '../../test-support'

module Skylab::Brazen::TestSupport::Data_Stores_

  ::Skylab::Brazen::TestSupport[ self ]

end

module Skylab::Brazen::TestSupport::Data_Stores_::Git_Config

  ::Skylab::Brazen::TestSupport::Data_Stores_[ self ]

  include CONSTANTS

  extend TestSupport_::Quickie

  Subject_ = -> do
    Brazen_::Data_Stores_::Git_Config
  end
end
