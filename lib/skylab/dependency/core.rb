require_relative '..'

require 'skylab/code-molester/core'
require 'skylab/face/core'
require 'skylab/porcelain/core'
require 'skylab/slake/core'

module Skylab::Dependency

  extend ::Skylab::MetaHell::MAARS

  CodeMolester = ::Skylab::CodeMolester
  Dependency = self
  Face = ::Skylab::Face
  Headless = ::Skylab::Headless
  Inflection = ::Skylab::Autoloader::Inflection
  Porcelain = ::Skylab::Porcelain
  PubSub = ::Skylab::PubSub
  Slake = ::Skylab::Slake

end
