module Skylab::TanMan

  class API::Service
                                  # experiment in pure-TDD rewrite

    def clear
      API.singletons.clear        # etc
    end

    attr_accessor :debug          # if truish, must be a writable stream

    def invoke name, params_h=nil
                                  # make a new client for each request, as
                                  # was always intended
      self.debug ||= API.debug    # for now

      response = API::Response.new

      client = API::Client.new self

      shared = -> o do            # ick for low-level invalid things we need
                                  # to hook into the client itself
        o.on_all do |e|
          if debug
            debug.puts "  >>> (api preview: #{[e.type, e.message].inspect })"
          end
          response.add_event e
          nil
        end
      end

      shared[ client ]

      response.result = client.invoke name, params_h, &shared

      response
    end

  protected

    def initialize
      @pen = Headless::API::IO::Pen::MINIMAL
    end

    attr_reader :pen
  end
end
