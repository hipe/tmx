require_relative '..'
require 'skylab/headless/core'
require 'skylab/pub-sub/core'

module ::Skylab::CodeMolester

  CodeMolester = self # a handle for autoloading unobtrustively
  Headless     = ::Skylab::Headless
  MetaHell     = ::Skylab::MetaHell
  PubSub       = ::Skylab::PubSub


  extend MetaHell::Autoloader::Autovivifying::Recursive
end
