require_relative '../test-support'

module Skylab::TanMan::Models::DotFile::Manipulus end
module Skylab::TanMan::Models::DotFile::Manipulus::TestSupport
  def self.extended mod
    mod.extend ModuleMethods
    mod.send :include, InstanceMethods
  end

  module ModuleMethods
    include ::Skylab::TanMan::Models::DotFile::TestSupport::ModuleMethods
  end

  module InstanceMethods
    extend ::Skylab::TanMan::TestSupport::InstanceMethodsModuleMethods
    include ::Skylab::TanMan::Models::DotFile::TestSupport::InstanceMethods

    let(:_parser_dir_path) { ::File.expand_path('..', __FILE__) }
  end
end
