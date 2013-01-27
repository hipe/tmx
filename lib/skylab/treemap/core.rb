require 'singleton' # [#048] - - singleton goes away

require_relative '..'
require 'skylab/face/core'
require 'skylab/porcelain/core'
require 'skylab/pub-sub/core'

module Skylab::Treemap
  [ :Autoloader,
    :Headless,
    :MetaHell,
    :Porcelain,
    :PubSub,
    :Treemap
  ].each do |c|
    const_set c, ::Skylab.const_get( c, false )
  end

  Bleeding = Porcelain::Bleeding

  extend MetaHell::Autoloader::Autovivifying::Recursive

  module Core
    extend MetaHell::Autoloader::Autovivifying::Recursive
  end
end
