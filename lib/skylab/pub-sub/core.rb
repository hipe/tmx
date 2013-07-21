require_relative '..'
require 'skylab/basic/core'

module Skylab::PubSub

  %i| Autoloader Basic MetaHell PubSub |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  MAARS = MetaHell::MAARS

  MAARS[ self ]

end
