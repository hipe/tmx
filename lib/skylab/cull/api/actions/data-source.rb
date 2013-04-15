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

  class API::Actions::DataSource::Add < API::Action

    params :name, :url, :tag_a, :is_dry_run

    emits error_event: :model_event, info_event: :model_event

    def execute
      v = true
      @client.model( :data, :sources ).
        add @name, @url, @tag_a, @is_dry_run, v,
          method( :error_event ), method( :info_event )
    end
  end
end
