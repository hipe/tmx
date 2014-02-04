require_relative '..'

require 'skylab/code-molester/core'
require 'skylab/face/core'
require 'skylab/porcelain/core'
require 'skylab/slake/core'

module Skylab::Dependency

  ::Skylab::MetaHell::MAARS[ self ]

  Autoloader = ::Skylab::Autoloader
  CodeMolester = ::Skylab::CodeMolester
  Dependency = self
  Face = ::Skylab::Face
  Headless = ::Skylab::Headless
  Porcelain = ::Skylab::Porcelain
  Callback = ::Skylab::Callback
  Slake = ::Skylab::Slake

end
