module Skylab::TanMan

  module CLI::NamespaceModuleMethods

    include Bleeding::NamespaceModuleMethods

    def self.extended mod
      MetaHell::Boxxy[ mod ]  # (satisfying [#023] - use boxxy-like)
    end

    def build request_client
      CLI::NamespaceRuntime.new request_client, self
    end
  end
end
