module Skylab::TanMan
  class Models::DotFile::Action < ::Struct.new(
    :dotfile_controller,
    :dry_run,
    :statement,
    :verbose
  )

    include Core::SubClient::InstanceMethods
    extend Headless::Parameter::Controller::StructAdapter

  protected

    def graph_noun
      request_client.graph_noun
    end
  end
end
