require 'singleton' # [#048] - - singleton goes away

require_relative '..'
require 'skylab/face/core'
require 'skylab/porcelain/core'
require 'skylab/pub-sub/core'

module Skylab::Treemap
  [ :Autoloader,
    :Headless,
    :Porcelain,
    :PubSub,
    :Treemap
  ].each do |c|
    const_set c, ::Skylab.const_get( c, false )
  end

  Bleeding = Porcelain::Bleeding

  require_relative 'meta-hell'    # sorry, there is some wankiness [#003]

  extend MetaHell::Autoloader::Autovivifying::Recursive

  module Core
    extend MetaHell::Autoloader::Autovivifying::Recursive
  end
end
