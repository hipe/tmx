module Skylab::Face

  class CLI::API_Integration::Services_

    # API-related services bound to a specific ns mechanics - for regret hack

    def initialize m
      define_singleton_method :hot_api_action_class do
        if (( cmd = m.last_hot ))
          i_a = cmd.anchorized_last
          m.api_client.action_const_fetch i_a
        end
      end
    end
  end
end
