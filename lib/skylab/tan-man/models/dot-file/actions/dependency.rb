module Skylab::TanMan
  class Models::DotFile::Actions::Dependency < ::Struct.new(
    :digraph,
    :statement
  )
    extend ::Skylab::Headless::Parameter::Controller::StructAdapter
    include API::Achtung::SubClient::InstanceMethods
    def execute
      info("IVE GOT OT REACH THESE KIDS: \"#{
        statement.agent.list.join(' ') } -> \"#{
        statement.target.list.join(' ') }\"")
    end
  end
end
