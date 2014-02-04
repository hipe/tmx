require_relative '..'

require 'skylab/callback/core'
require 'skylab/face/core'
require 'skylab/headless/core'

module Skylab

  module Porcelain

    %i| Callback Face Headless MetaHell Porcelain |.each do |i|
      const_set i, ::Skylab.const_get( i, false )
    end

    # headless in porcelain yes. headles trumps porcelain.

    MAARS = MetaHell::MAARS

    MAARS[ self ]
  end
end
