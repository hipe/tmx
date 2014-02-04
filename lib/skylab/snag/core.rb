require_relative '..'

require 'skylab/porcelain/core'

module Skylab::Snag

  %i| Autoloader Headless MetaHell Porcelain Callback Snag |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  module Core
    MetaHell::MAARS[ self ]
  end

  IDENTITY_ = -> x { x }

  ::Skylab::Subsystem[ self ]

end
