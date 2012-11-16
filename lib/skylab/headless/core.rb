require 'skylab/meta-hell/core'

module Skylab::Headless
  extend ::Skylab::MetaHell::Autoloader::Autovivifying
  Headless = self

  module CONSTANTS
    MUSTACHE_RX = / {{ ( (?: (?!}}) [^{] )+ ) }} /x
  end
end
