module Skylab::Treemap
  module Core::SubClient
  end

  module Core::SubClient::InstanceMethods
    extend MetaHell::DelegatesTo # sic #while [#003]

    include Headless::NLP::EN::Methods # this is in porcelain bleeding but
                                  # fortunately we are not always that.

  protected

    delegates_to :stylus,
      :and_,
      :bad_value,
      :em,
      :escape_path,
      :kbd,
      :or_,
      :pre,
      :param,
      :s,
      :value

    def adapter_box
      request_client.send :adapter_box
    end

    def api_client
      request_client.send :api_client
    end

    def info msg, *meta           # api acts e.g. use this
      emit :info, msg, *meta
      nil
    end

    def error msg, *meta          # this is used by root mode client
      emit :error, msg, *meta
      @error_count += 0           # this is part of the contract
      false
    end

    def normalized_invocation_string # # we will assume you are doing the right
      # thing and being a *cli* sub-client (action) when you invoke this.
      # things can be splayed out as needed.
      "#{ request_client.send :normalized_invocation_string } #{
        }#{ normalized_local_name }"
    end

    def stylus
      request_client.send :stylus
    end
  end
end
