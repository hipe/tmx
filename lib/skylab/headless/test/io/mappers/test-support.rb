require_relative '../test-support'

module Skylab::Headless::TestSupport::IO::Interceptors

  ::Skylab::Headless::TestSupport::IO[ self ]

  include CONSTANTS # so we can say Headless_ inside the describe block

  Headless_::Library_.const_get :StringIO, false

  extend TestSupport_::Quickie

end
