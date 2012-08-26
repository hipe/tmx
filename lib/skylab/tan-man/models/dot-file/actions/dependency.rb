module Skylab::TanMan
  class Models::DotFile::Actions::Dependency <
    ::Struct.new(:path, :statement, :runtime)
    extend ::Skylab::Headless::Parameter::Controller::StructAdapter
    def execute
      info("YOWZAL #{runtime.class}")
    end
  end
end
