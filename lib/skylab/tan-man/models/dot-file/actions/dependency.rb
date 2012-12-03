module Skylab::TanMan
  class Models::DotFile::Actions::Dependency < ::Struct.new(
    :digraph,
    :statement
  )
    extend ::Skylab::Headless::Parameter::Controller::StructAdapter
    def execute
      info("IVE GOT OT REACH THESE KIDS: \"#{
        statement.agent.words.join(' ') }\" -> \"#{
        statement.target.words.join(' ') }\"")
    end
  end
end
