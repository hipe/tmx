require_relative '../test-support'

module Skylab::Callback::TestSupport::Scn::Articulators

  ::Skylab::Callback::TestSupport::Scn[ self ]

  module Constants

    NEWLINE_ = ::Skylab::Callback::TestSupport::NEWLINE_

    Subject_ = -> do
      Callback_::Scn.articulators
    end
  end
end
