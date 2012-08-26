module Skylab::TanMan
  module Models::DotFile end
  class Models::DotFile::Controller < ::Struct.new(:path, :statement)
    extend ::Skylab::Headless::Parameter::Controller::StructAdapter
    def execute
      _const = statement.class.nt_const.match(/\A.+(?=Statement\z)/)[0]
      _class = Models::DotFile::Actions.const_get(_const)
      _class.new(request_runtime).invoke(
        path: path, statement: statement, runtime: self)
    end
  end
end
