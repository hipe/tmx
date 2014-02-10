require_relative '..'

require 'skylab/porcelain/core'

module Skylab::Snag

  %i| Autoloader Headless MetaHell Porcelain Callback Snag |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  MetaHell::MAARS[ self ]

  module Core
    MetaHell::MAARS::Upwards[ self ]
  end

  IDENTITY_ = -> x { x }

end
