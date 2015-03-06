require_relative '../test-support'

module Skylab::TMX::TestSupport::CLI

  ::Skylab::TMX::TestSupport[ self ]

  include Constants

  Face_::TestSupport::CLI::Client[ self ]  # tons of stuff from here

  module Constants

    o = ::Skylab::TMX

    DASH_ = o::DASH_

    EMPTY_S_ = o::EMPTY_S_

    NEWLINE_ = "\n".freeze

    SIMPLER_STYLE_RX_ = %r(\e\[\d+m)

    SPACE_ = ' '.freeze

    UNDERSCORE_ = '_'.freeze

  end
end
