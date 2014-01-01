module Skylab::GitViz

  class API::Actions::Ping < API::Action

    def invoke
      svcs.y << "hello from git viz."
      :hello_from_git_viz
    end
  end
end
