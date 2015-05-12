require_relative '../core'

Skylab::Human::Autoloader_.require_sidesystem :TestSupport

module Skylab::Human::TestSupport

  TestSupport_ = ::Skylab::TestSupport

  TestSupport_::Regret[ self ]

  extend TestSupport_::Quickie

  Hu_ = ::Skylab::Human

end
