require_relative '..'

require 'skylab/headless/core'
require 'skylab/pub-sub/core'

module Skylab

  module Porcelain

    %i| Headless MetaHell PubSub |.each do |i|
      const_set i, ::Skylab.const_get( i, false )
    end

    # headless in porcelain yes. headles trumps porcelain.

    MAARS = MetaHell::MAARS

    extend MAARS
  end
end
