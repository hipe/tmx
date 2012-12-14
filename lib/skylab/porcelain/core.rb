require_relative '..'
require 'skylab/headless/core'

module Skylab
  module Porcelain
    Headless = ::Skylab::Headless # i win
    extend ::Skylab::MetaHell::Autoloader::Autovivifying
  end
end
