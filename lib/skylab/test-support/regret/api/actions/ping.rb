module Skylab::TestSupport::Regret::API

  class API::Actions::Ping < API::Action

    services [ :err, :ivar ]

    def execute
      @err.puts "hello from regret."
      :hello_from_regret
    end
  end
end
