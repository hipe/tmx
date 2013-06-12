module Skylab::TestSupport::Regret::API

  class API::Actions::Ping < Face::API::Action

    services [ :err, :ingest ]

    def execute
      @err.puts "hello from regret."
      :hello_from_regret
    end
  end
end
