module Skylab::TanMan

  class Services::API
                                  # experiment in pure-TDD rewrite

  public

    def clear
      API.singletons.clear        # etc
    end


    def invoke name_a, params_h=nil, upstream_client=nil, events=nil

      debug = API.debug           # just for this request, within this call

      response = nil              # if an events callable was not provided,
      if ! events                 # then caller gets all the events at end.
        response = API::Response.new # (stream and tree are mutex for now)
        events = -> o do          # for low-level invalid things this will hook
          o.on_all do |e|         # into the client itself as well as the action
            if debug
              debug.puts "  >>> (api preview: #{[e.type, e.message].inspect })"
            end
            response.add_event e
            nil
          end
        end
      end
                                  # make a new client for each request, as
      api_client = nil            # was always intended
      if upstream_client          # if there's an upstream client assume it
        api_client = API::Client.new upstream_client # has a pen we can borrow
      else                        # otherwise it's ok because we brought
        api_client = API::Client.new :derk # our own
        api_client.pen = Headless::API::IO::Pen::MINIMAL
      end

      r = api_client.invoke name_a, params_h, events
      if response
        response.result = r
      else
        response = r
      end
      response
    end

  protected

    # none

  end
end
