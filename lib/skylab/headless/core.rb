require_relative '..'
require 'skylab/meta-hell/core'

module Skylab::Headless
  extend ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive

  Autoloader = ::Skylab::Autoloader
  Headless = self
  MetaHell = ::Skylab::MetaHell

  module CONSTANTS
    MUSTACHE_RX = / {{ ( (?: (?!}}) [^{] )+ ) }} /x
  end
end
