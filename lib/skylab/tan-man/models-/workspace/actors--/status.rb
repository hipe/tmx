module Skylab::TanMan

  class API::Actions::Status < API::Action   # due for a refactor [#041]
    # (as it is it's a nifty proof of concept of complex event graphs,
    # but let's get that ee.push b.s out of here and make it headless)

    TanMan::Sub_Client[ self,
      :attributes,
        :required, :pathname, :attribute, :path ]

    emits :all, negative: :all, positive: :all, global: :all, local: :all,
      local_positive: [:local, :positive],
      local_negative: [:local, :negative],
      global_positive: [:global, :positive],
      global_negative: [:global, :negative],
      local_found: :local_positive,
      global_found: :global_positive

  private

    def execute
      events = -> do
        a = []
        services.config.ready? do |o| # compare to config/controller.rb

          o.escape_path = ->( p ) { escape_path p } # per modality!

          o.not_ready = -> e do
            a.push build_event(:local_negative,  e)
          end

          o.global_invalid = -> e do
            a.push build_event(:global_negative, e)
          end

          o.local_invalid = -> e do
            a.push build_event(:local_negative, e)
          end

        end
        a
      end.call

      service = services.config
      if ! events.index { |e| e.is? :global }
        if service.global.exist?
          ev = build_event :global_found,
            message: "#{ escape_path service.global.pathname }",
            pathname: service.local.pathname
          events.push ev
        else
          events.push build_event(:global_positive, 'not found')
        end
      end

      if ! events.index { |e| e.is? :local_negative }
        if service.local.exist?
          ev = build_event :local_found,
            message: service.local.pathname.to_s,
            pathname: service.local.pathname
          events.push ev
        else
          ev = build_event :local_found,
            message: "#{ service.local.pathname.dirname.to_s }/",
            pathname: service.local.pathname
          events.push ev
        end
      end
      events
    end
  end
end
