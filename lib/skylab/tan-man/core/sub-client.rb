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

    def infostream
      request_client.send :infostream
    end

    def parent # adapt to bleeding for now [#018]
      request_client
    end

    def services
      request_client.send :services
    end

    def skip msg
      emit :skip, msg
      nil
    end

  end
end
