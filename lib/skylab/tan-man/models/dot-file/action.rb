module Skylab::TanMan
  class Models::DotFile::Action < ::Struct.new(
    :dotfile_controller,
    :dry_run,
    :force,
    :statement,
    :verbose
  )

    include Core::SubClient::InstanceMethods
    extend Headless::Parameter::Controller::StructAdapter

  private

    def graph_noun
      request_client.graph_noun
    end
  end
end
