module Skylab::TanMan


  module Core::SubClient
    # per headless sub-client pattern, what we have here will be behavior
    # and implementation common to most *all* clients *and* actions *and*
    # ad-hoc controllers across most *all* modalities!


    # not every class/module that will want one will want both m.m / i.m !
    def self.extended mod
      mod.extend Core::SubClient::ModuleMethods
      mod.send :include, Core::SubClient::InstanceMethods
    end
  end



  module Core::SubClient::ModuleMethods
    include MetaHell::DelegatesTo
    include Porcelain::Attribute::Definer
  end



  module Core::SubClient::InstanceMethods

    include Headless::SubClient::InstanceMethods # mostly delegators


  protected

    def config_singleton
      request_client.send :config_singleton # [#021]
    end

    def infostream
      request_client.send :infostream
    end

    def parent # adapt to bleeding for now [#018]
      request_client
    end

    def service
      request_client.send :service
    end

    def singletons                # away at [#021]
      request_client.send :singletons
    end

    def skip msg
      emit :skip, msg
      nil
    end

  end
end
