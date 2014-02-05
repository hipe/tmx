require_relative '../test-support'

module Skylab::Headless::TestSupport::IO::Interceptors

  ::Skylab::Headless::TestSupport::IO[ self ]

  include CONSTANTS # so we can say Headless inside the describe block

  Headless::Library_.const_get :StringIO, false

  extend TestSupport::Quickie

end
