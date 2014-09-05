module Skylab::TanMan

  class Services::API
                                  # experiment in pure-TDD rewrite

  public

    def clear_all_services        # put your seatbelt on, becase you were
      Services.config.clear_config_service  # really asking for it
      Services.tree.clear_tree_service
      nil
    end


    define_method :invoke do |name_a, param_h=nil, upstream_client=nil,
                                                                     events=nil|
      do_debug = API.do_debug ; debug_stream = API.debug_stream
                                  # just for this request, within this call

      response = nil              # if an events callable was not provided,
      if ! events                 # then caller gets all the events as result
        response = API::Response.new # (stream and tree are mutex for now).
        events = -> o do          # this will hook into the action and, for
          o.on_all do |e|         # low-level invalid things, the client itself
            if do_debug
              debug_stream.puts "  >>> (api preview: #{[e.stream_name, e.message].inspect })"
            end
            response.add_event e
            nil
          end
        end
      end

      api_client = API::Client.new(* [ upstream_client ].compact ) # make a new
                                  # client for each request, as was always
                                  # intended. Provide the upstream client if
                                  # one exists so we can do modality-aware
                                  # things like using modality-specific pens.
                                  # the funny syntax is a sanity check on
                                  # the formal parameters
      r = api_client.invoke name_a, param_h, events
      if response
        response.result = r
      else
        response = r
      end
      response
    end

  private

    # none

  end
end
