require_relative '..'

require 'skylab/face/core'
require 'skylab/porcelain/core'


module Skylab::TMX

  # (for each required internal library and sub-product constant, make a local
  # such constant here under our own for readability and ease of refactoring:)

  %i| Autoloader Face MetaHell Porcelain TMX |.each do |c|  # self too
    const_set c, ::Skylab.const_get( c, false )
  end

  MetaHell::MAARS[ self ]
    # now any module under `self` will autoload.

  module TMX::Modules

    # this isomorphs with the filesystem and is used to that end.
    # (note that generated namespaces will go in a sister module)

    MetaHell::Boxxy[ self ]

  end

  module CLI  # #stowaway this tiny thing here

    MetaHell::MAARS[ self ]

    def self.new *a
      self::Client.new( *a )
    end
  end
end
