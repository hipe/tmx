require_relative '../test-support'

module ::Skylab::TanMan::Sexp::TestSupport::Prototype # #new-pattern
  module Grammars
    extend ::Skylab::TanMan::Sexp::TestSupport::Grammar::Boxxy
  end
  def self.extended mod
    mod.extend ModuleMethods
    mod.send :include, InstanceMethods
  end
  module ModuleMethods
    include ::Skylab::TanMan::Sexp::TestSupport::ModuleMethods
  end
  module InstanceMethods
    extend ::Skylab::TanMan::TestSupport::InstanceMethodsModuleMethods
    include ::Skylab::TanMan::Sexp::TestSupport::InstanceMethods
    let :_parser_clients_module do
      ::Skylab::TanMan::Sexp::TestSupport::Prototype::Grammars
    end
  end
end
