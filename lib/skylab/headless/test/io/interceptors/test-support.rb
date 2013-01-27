require_relative '../test-support'

module Skylab::Headless::TestSupport::IO::Interceptors
  ::Skylab::Headless::TestSupport::IO[ self ]

  include CONSTANTS # so we can say Headless inside the describe block

  Headless::Services.const_get :StringIO, false # load it

  extend TestSupport::Quickie

end
