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

    def message= msg
      update_attributes! message: msg
    end

    def to_json *a
      json_data.to_json(*a)
    end
  end
end
