module Skylab::TanMan

  # We built out a sophisticated event-graph-laden codebase here well before
  # we had the big epiphany of event factories - so, sadly we do late
  # binding of an emission to its event class based on the shape of the
  # payload. our hopes and dreams for this are tracked by [#076]

  module API::Event
  end

  class API::Event::Stringular < PubSub::Event::Unified  # `is?`

    class << self
      alias_method :event, :new
    end

    include Core::Event::LingualMethods

    def json_data
      {
        stream_name: stream_name,
        shape: :textual,
        payload: message
      }
    end

  private

    def initialize a, b, c=nil
      super a, b
      init_lingual c if c
    end
  end

  class API::Event::Structural < PubSub::Event::Unified

    # fill it with joy, fill it with sadness

    include Core::Event::LingualMethods

    -> do

      monadic_a = [ ::String, ::TrueClass, ::Fixnum, ::Float ]

      # hackish sanity check. just a sketch

      define_method :json_data do
        arr = self.class.members.reduce [] do |m, k|
          x = send k
          m << [ k, x ] if ! x || monadic_a.include?( x.class )
          m
        end
        h = arr.length.zero? ? true : ::Hash[ arr ]
        {
          stream_name: stream_name,
          shape: :structural,
          payload: h
        }
      end
    end.call
  end

  module API::Event::Mappings

    String = API::Event::Stringular

    Hash = PubSub::Event::Factory::Structural.new 20,
      API::Event::Structural, API::Event::Structural  # base kls & box module

  end

  API::Event::Rewrap = -> esg, stream_name, e do

    # we want the same metadata values (and we will probably use the
    # same produced class) (or if it's a textual event, we want the
    # same text) but we need the unified event object to know
    # about its event stream graph, and that graph will be different
    # than that of the upstream event.
    #
    # (note this will break when you get a textual event. consider
    # actually routing through the `late` factory!)

    API::Event::Mappings::Hash.event esg, stream_name, e.to_hash
  end

  API::Event::Factory = PubSub::Event::Factory::Late.new(
    API::Event::Mappings, API::Event::Rewrap )
end
