require_relative '..'

require 'skylab/face/core'

module Skylab::Git

  p = -> m, a do
    a.each { |i| const_set i, m.const_get( i, false ) }
  end

  p[ ::Skylab, %i| Face Git MetaHell | ]

  MAARS = MetaHell::MAARS

  p[ Face::FUN, %i| Stdin_ Stdout_ Stderr_ | ]

  module CLI

    MAARS[ self ]

    def self.new sin, sout, serr
      CLI::Client.new sin, sout, serr
    end
  end

  MAARS[ self ]
end
