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

    def _tan_man_sub_client_init! request_client
      _headless_sub_client_init! request_client
    end

    def controllers
      request_client.send :controllers
    end

    def escape_path *a            # (we wanted this to go away with [#hl-031]
      pen.escape_path(* a)        # but tan-man apparently thinks it has
    end                           # special needs.)


    rx = Headless::CLI::PathTools::FUN.absolute_path_hack_rx
    define_method :gsub_path_hack do |str|
      res = str.gsub rx do
        escape_path "#{ $~[0] }" # (delegates to the modality-specific pen)
      end
      res
    end


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
