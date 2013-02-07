module Skylab::TanMan

  class API::Event < Core::Event
    # this is all very experimental and subject to change!

    def json_data
      case payload
      when ::String, ::Hash ; [ stream_name, payload ]
      when ::Array          ; [ stream_name, *payload ]
      else                  ; [ stream_name ] # no payload for you!
      end
    end
  end
end
