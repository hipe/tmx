module Skylab::TanMan

  module CLI::NamespaceModuleMethods
    # to be audited at [#023] for something boxxy-like
    include Bleeding::NamespaceModuleMethods

    def build request_client
      o = CLI::NamespaceRuntime.new request_client, self
      o
    end
  end
end
