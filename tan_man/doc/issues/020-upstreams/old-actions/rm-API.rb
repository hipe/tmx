module Skylab::TanMan

  class API::Actions::Remote::Rm < API::Action

    TanMan::Sub_Client[ self,
      :attributes,
        :required, :attribute, :remote_name,
        :attribute, :resource_name, :mutex_boolean_set, [ :local, :global ] ]

    attr_reader :verbose

  private

    def execute
      result = nil
      begin
        controllers.config.ready? or break
        result = controllers.config.remove_remote remote_name, resource_name
        result ||= false
      end while nil
      result
    end
  end
end
