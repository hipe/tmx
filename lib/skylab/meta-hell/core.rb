require_relative '../../skylab'

module Skylab
  module MetaHell
    MetaHell = self
    extend ::Skylab::Autoloader
    module Autoloader
      extend ::Skylab::Autoloader
    end
    extend MetaHell::Autoloader::Autovivifying::ModuleMethods # MWAHAHAHA stupid
  end
end
