module Skylab::TanMan

  class API::Response < ::Struct.new :result, :events

    def add_event event
      events.push event
    end

    def success?                  # this is how you define it
      ! events.detect { |e| e.is? :error }
    end

    def to_json state, i
      as_array = events.map { |e| e.json_data }
      json = as_array.to_json state, i
      json
    end

  protected

    def initialize
      super nil, [ ]
    end

    def json_data
      events.map(& :json_data)
    end
  end
end
