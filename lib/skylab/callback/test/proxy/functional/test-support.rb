require_relative '../test-support'

module Skylab::Callback::TestSupport::Proxy::Functional

  # (this may or may not be in active duty but is kept around
  #  for whenever we resucitate the generated spec file)

  ::Skylab::Callback::TestSupport::Proxy[ self ]

  include Constants

  extend TestSupport_::Quickie

  Home_ = Home_

  Subject_ = -> do
    Home_::Proxy
  end

end
