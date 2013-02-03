module Skylab::TanMan

  module CLI::NamespaceModuleMethods
    # to be audited at [#023] for something boxxy-like
    include Bleeding::NamespaceModuleMethods
    include MetaHell::Boxxy::ModuleMethods

    def self.extended mod
      mod._boxxy_init caller[0]
    end

    def build request_client
      o = CLI::NamespaceRuntime.new request_client, self
      o
    end
  end
end
