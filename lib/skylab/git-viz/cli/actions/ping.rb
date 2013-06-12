module Skylab::GitViz

  class CLI::Actions::Ping < CLI::Action

    def invoke h

      x = api.invoke h

      x
    end
  end
end
