require_relative '..'

require 'skylab/code-molester/core'
require 'skylab/face/core'
require 'skylab/headless/core'
require 'skylab/meta-hell/core'
require 'skylab/porcelain/core'
require 'skylab/pub-sub/core'
require 'skylab/slake/core'

module Skylab::Dependency
  extend ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive

  CodeMolester = ::Skylab::CodeMolester
  Dependency = self
  Face = ::Skylab::Face
  Headless = ::Skylab::Headless
  Inflection = ::Skylab::Autoloader::Inflection
  Porcelain = ::Skylab::Porcelain
  PubSub = ::Skylab::PubSub
  Slake = ::Skylab::Slake

end
