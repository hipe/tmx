module Skylab::PubSub

  class Event::Factory::Late

    # a forward-fitting factory for old event models that only had one
    # event class that could variously be strings or structured based
    # on how the payload data looked.  Please don't use this for new code -
    # it is intended to help adapt old code to the New Way.

    def call esg, stream_name, payload_x
      name = payload_x.class.name
      if name.index ':'
        rewrap esg, stream_name, payload_x
      else
        fact = @const_getter.const_get name.intern, false
        fact.event esg, stream_name, payload_x
      end
    end

    alias_method :[], :call  # look like a ::Proc

  private

    def initialize const_getter, rewrap = nil
      @const_getter = const_getter
      @rewrap = rewrap
    end

    def rewrap esg, stream_name, payload_x
      if @rewrap
        @rewrap[ esg, stream_name, payload_x ]
      else
        payload_x  # meh.
      end
    end
  end
end
