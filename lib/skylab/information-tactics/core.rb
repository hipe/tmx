require_relative '..'
require 'skylab/meta-hell/core'

module Skylab::InformationTactics

  ::Skylab::MetaHell::FUN::
    Import_constants[ ::Skylab, %i( MetaHell InformationTactics ), self ]

  MetaHell::MAARS[ self ]

  ::Skylab::Subsystem[ self ]

end
