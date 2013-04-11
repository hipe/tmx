module Skylab::Cull

  module API::Actions::DataSource

  end

  class API::Actions::DataSource::List < API::Action

    params  # no params

    emits :payload_line, error_event: :model_event

    def execute
      @client.model( :data, :sources ).
        list method( :payload_line ), method( :error_event )
    end
  end
end
