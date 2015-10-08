module Skylab::TanMan

  class API::Actions::Remote::Add < API::Action

    TanMan::Sub_Client[ self,
      :attributes,
        :required, :attribute, :host,
        :required, :attribute, :name,
        :attribute, :resource, :default, :local,
          :mutex_boolean_set, [ :local, :global ] ]

      attr_reader :name  # covered, hacky

    attr_reader :verbose # compat

  private

    def execute
      result = nil
      begin
        controllers.config.ready? or break
        result = controllers.config.add_remote name, host, resource
      end while nil
      result
    end
  end
end
