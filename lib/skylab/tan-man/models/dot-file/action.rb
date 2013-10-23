module Skylab::TanMan
  class Models::DotFile::Action < ::Struct.new(
    :dotfile_controller,
    :dry_run,
    :force,
    :statement,
    :verbose
  )

    include Core::SubClient::InstanceMethods

    Headless::Parameter[ self, :parameter_controller_struct_adapter, :oldschool_parameter_error_structure_handler ]

    public :pen

  private

    def graph_noun
      request_client.graph_noun
    end
  end
end
