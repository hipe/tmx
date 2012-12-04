require_relative '..'

require 'skylab/face/core'
require 'skylab/porcelain/core'
require 'skylab/pub-sub/core'

module ::Skylab::CodeMolester
  extend ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive

  CodeMolester = self # a handle for autoloading unobtrustively
  En       = ::Skylab::Porcelain::En
  Face     = ::Skylab::Face
  MetaHell = ::Skylab::MetaHell
  PubSub   = ::Skylab::PubSub
end
