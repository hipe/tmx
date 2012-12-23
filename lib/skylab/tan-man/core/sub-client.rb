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

    def initialize request_client              # have fun with this!
      _tan_man_sub_client_init! request_client
    end

    def _tan_man_sub_client_init! request_client
      _headless_sub_client_init! request_client
    end

    def api_invoke normalized_action_name, param_h # *EXPERIMENTAL*
      services.api.invoke normalized_action_name, param_h, self, -> o do
        o.on_all { |event| emit event }
      end
    end

    def controllers
      request_client.send :controllers
    end

    def collections
      request_client.send :collections
    end

    def escape_path *a            # (we wanted this to go away with [#hl-031]
      pen.escape_path(* a)        # but tan-man apparently thinks it has
    end                           # special needs.)

    def hdr s                     # how do we render headers (e.g. in report
      em s                        # tables?)
    end

    rx = Headless::CLI::PathTools::FUN.absolute_path_hack_rx
    define_method :gsub_path_hack do |str|
      res = str.gsub rx do
        escape_path "#{ $~[0] }" # (delegates to the modality-specific pen)
      end
      res
    end

    def ick x                     # similar to `val` but for rendering an
      pen.ick x                   # invalid value.. in some modes they look
    end                           # better when these have quotes

    def infostream
      request_client.send :infostream
    end

    def lbl str                   # render the label for a business name
      pen.lbl str
    end

    def par sym                   # modality-specific [#hl-036] parameter
      pen.par sym                 # rendering
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

    def val x                     # render a business value
      pen.val x
    end
  end
end
