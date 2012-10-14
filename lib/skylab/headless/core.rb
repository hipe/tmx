require 'skylab/meta-hell/core'

module Skylab::Headless
  extend ::Skylab::MetaHell::Autoloader::Autovivifying
  Headless = self

  module Constants
    MUSTACHE_RX = / {{ ( (?: (?!}}) [^{] )+ ) }} /x
  end
end
