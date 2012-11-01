module Skylab::TanMan
  class Models::DotFile::Controller < ::Struct.new(:pathname, :statement)
    extend ::Skylab::Headless::Parameter::Controller::StructAdapter
    include ::Skylab::Autoloader::Inflection::Methods # constantize
    include API::Achtung::SubClient::InstanceMethods # info
    include Models::DotFile::Parser::InstanceMethods

    def check
      result = parse_file pathname
      info "OK in dot-file/controller.rb we got something .."
      require 'pp' ; ::PP.pp result
      true
    end

    # execute a statement
    def execute
      action_class = Models::DotFile::Actions.const_get(
        constantize(statement.class.rule.to_s.match(/_statement\z/).pre_match))
      action_class.new(request_runtime).invoke(
        digraph: self,
        statement: statement
      )
    end
  protected
    def initialize request_runtime, pathname = nil
      self.request_runtime = request_runtime
      self.pathname = pathname
    end
  end
end
