require_relative '..'
require 'skylab/meta-hell/core'

module Skylab::InformationTactics

  ::Skylab::MetaHell::FUN.import[ self, ::Skylab,
    %i| MetaHell InformationTactics | ]

  MetaHell::MAARS[ self ]

  ::Skylab::Subsystem[ self ]

end
