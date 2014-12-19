require_relative '../test-support'

module Skylab::MetaHell::TestSupport::Fields

  ::Skylab::MetaHell::TestSupport[ self ]

end

module Skylab::MetaHell::TestSupport::Fields::From

  ::Skylab::MetaHell::TestSupport::Fields[ self ]

  include Constants

  extend TestSupport_::Quickie

  MetaHell_ = MetaHell_

end
