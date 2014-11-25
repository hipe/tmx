module Skylab::TestSupport

  module Regret::API

  class Actions::Ping < API_::Action

    services [ :err, :ivar ]

    def execute
      @err.puts "hello from regret."
      :hello_from_regret
    end
  end
  end
end
