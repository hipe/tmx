module Skylab::TanMan
  class Models::DotFile::Controller < ::Struct.new(:pathname, :statement)
    extend ::Skylab::Headless::Parameter::Controller::StructAdapter
    def execute
      nt_const = statement.class.nt_const.match(/\A.+(?=Statement\z)/)[0]
      action = Models::DotFile::Actions.const_get(nt_const)
      action.new(request_runtime).invoke(
        digraph: self,
        statement: statement
      )
    end
  end
end
