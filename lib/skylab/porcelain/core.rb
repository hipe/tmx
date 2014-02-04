require_relative '..'

require 'skylab/headless/core'
require 'skylab/callback/core'

module Skylab

  module Porcelain

    %i| Callback Headless MetaHell Porcelain |.each do |i|
      const_set i, ::Skylab.const_get( i, false )
    end

    # headless in porcelain yes. headles trumps porcelain.

    MAARS = MetaHell::MAARS

    MAARS[ self ]
  end
end
