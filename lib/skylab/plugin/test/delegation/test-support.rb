require_relative '../test-support'

module Skylab::Plugin::TestSupport::Delegation_TS

  parent = ::Skylab::Plugin::TestSupport

  parent[ TS_ = self ]

  extend parent::TestSupport_::Quickie

  Home_ = parent::Home_

  Subject_ = Home_::Delegation

end
