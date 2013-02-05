module Skylab::Treemap
  module Core::SubClient
  end

  module Core::SubClient::InstanceMethods
    extend MetaHell::DelegatesTo # sic #while [#003]

    include Headless::NLP::EN::Methods # this is in porcelain bleeding but
                                  # fortunately we are not always that.

  protected

    def _treemap_sub_client_init rc=nil
      if rc
        if rc.respond_to? :call
          @rc = rc
          @request_client = nil
        else
          @rc = nil
          @request_client = rc
        end
      else
        @rc = @request_client = nil
      end
      @error_count = 0
      nil
    end

    delegates_to :stylus,
      :and_,
      :em,
      :escape_path,
      :hdr,
      :ick,
      :kbd,
      :or_,
      :pre,
      :param,
      :s,
      :val

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
        }#{ name.to_slug }"
    end

    def request_client
      @rc ? @rc.call : @request_client
    end

    def stylus
      request_client.send :stylus
    end
  end

  module Core::Action  # sorry, avoiding orphan
  end

  module Core::Action::InstanceMethods

    include Headless::Action::InstanceMethods
    include Core::SubClient::InstanceMethods

  end
end
