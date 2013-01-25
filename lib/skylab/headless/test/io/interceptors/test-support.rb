require_relative '../../test-support'

module Skylab::Headless::TestSupport::IO::Interceptors
  # CAREFUL - skipping IO in the chain b/c right now it is only cosmetic
  ::Skylab::Headless::TestSupport[ self ]

  include CONSTANTS # so we can say Headless inside the describe block

  Headless::Services.const_get :StringIO, false # load it

  extend TestSupport::Quickie

end
