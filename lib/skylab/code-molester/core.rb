require_relative '..'
require 'skylab/face/core'
require 'skylab/headless/core'
require 'skylab/porcelain/core'
require 'skylab/pub-sub/core'

module ::Skylab::CodeMolester

  CodeMolester = self # a handle for autoloading unobtrustively
  Face         = ::Skylab::Face
  Headless     = ::Skylab::Headless
  MetaHell     = ::Skylab::MetaHell
  Porcelain    = ::Skylab::Porcelain
  PubSub       = ::Skylab::PubSub


  extend MetaHell::Autoloader::Autovivifying::Recursive
end
