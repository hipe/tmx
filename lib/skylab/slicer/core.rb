require_relative '..'
require 'skylab/face/core'
require 'skylab/meta-hell/core'

module Skylab::Slicer

  %i| Face MetaHell Slicer |.each do |i|
    const_set i, ::Skylab.const_get( i, false )
  end

  MAARS = MetaHell::MAARS

  # (:+[#su-001]:none)

  MAARS[ self ]

end
