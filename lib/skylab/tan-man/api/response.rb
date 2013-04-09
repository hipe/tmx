module Skylab::TanMan

  class API::Response < ::Struct.new :result, :events

    def add_event event
      events.push event
    end

    def error
      events.detect { |e| e.is? :error }
    end

    def success?                  # this is how you define it
      ! error
    end

    def to_json state
      as_array = events.map { |e| e.json_data }
      json = as_array.to_json state
      json
    end

  protected

    def initialize
      super nil, [ ]
    end

    def json_data
      events.map(& :json_data )
    end
  end
end
