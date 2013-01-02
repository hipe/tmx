require 'skylab/headless/core'

module Skylab::FileMetrics
  extend ::Skylab::MetaHell::Autoloader::Autovivifying
  Common && Models # shh

  Headless = ::Skylab::Headless
end
