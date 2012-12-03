module Skylab::TanMan
  class API::Event < Core::Event
    # this is all very experimental and subject to change!

    def json_data
      case payload
      when ::String, ::Hash ; [tag.name, payload]
      when ::Array          ; [tag.name, *payload]
      else                  ; [tag.name] # no payload for you!
      end
    end
  end
end
