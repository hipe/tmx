require_relative '../test-support'

module Skylab::TanMan::Models::DotFile::TestSupport
  extend ::Skylab::MetaHell::Autoloader::Autovivifying
  self.dir_path = dir_pathname.join('..').to_s

  TanMan = ::Skylab::TanMan

  def self.extended mod
    mod.extend ModuleMethods
    mod.send :include, InstanceMethods
  end

  module ModuleMethods
    include TanMan::Models::TestSupport::ModuleMethods
  end

  module InstanceMethods
    extend TanMan::TestSupport::InstanceMethodsModuleMethods
    include TanMan::Models::TestSupport::InstanceMethods

    let :_input_fixtures_dir_path do
      TanMan::Models::DotFile::TestSupport::Fixtures.dir_path
    end
  end
end
