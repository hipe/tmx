module Skylab::TanMan  # (leave extra whitespacing below for [#bs-010])


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

    Headless::Delegating[ self, :employ_the_DSL_method_called_delegates_to ]  # this is a non-functionnig line to help during #de-integration

    include MetaHell::Formal::Attribute::Definer
  end



  module Core::SubClient::InstanceMethods

    include Headless::SubClient::InstanceMethods # mostly delegators


  private

    def initialize client_x=nil
      super( * client_x )
    end

    def client_notify client_x
      headless_client_notify client_x ; nil
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

                                  # generic fuzzy finder
                                  # `match` receives each item and should result
                                  # in 1 when exact match, zero / falseish when
    fuzzy_fetch = -> enum, match, not_found, ambiguous, fly_collapse=nil do
      fly_collapse ||= IDENTITY_  # no match or other when partial match.
      exact = exact_found = nil   # short-circuit on first exact match,
      count = 0                   # that is result. otherwise `not_found` or
      partial = [ ]               # `ambiguous` called as appropriate..
      enum.each do |item|
        count += 1
        flot = match[ item ]
        if flot && 0 != flot
          if 1 == flot
            exact_found = true
            exact = fly_collapse[ item ]
            break
          end
          partial.push fly_collapse[ item ]
        end
      end
      if exact_found
        res = exact
      else
        case partial.length
        when 0
          res = not_found[ count ]
        when 1
          # maybe add an info hook one day..
          res = partial.first
        else
          res = ambiguous[ partial ]
        end
      end
      res
    end

    define_method :fuzzy_fetch, & fuzzy_fetch

    o = { fuzzy_fetch: fuzzy_fetch }
    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

    def hdr s                     # how do we render headers (e.g. in report
      em s                        # tables?)
    end

    rx = Headless::CLI::PathTools::FUN::ABSOLUTE_PATH_HACK_RX
    define_method :gsub_path_hack do |str|  # replaced by [#cb-052]
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
