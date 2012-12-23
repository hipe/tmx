module Skylab::TanMan
  class Models::DotFile::Actions::Dependency < Models::DotFile::Action
  protected
    def execute
      agent = statement.agent.words.join ' '
      target = statement.target.words.join ' '
      api_invoke [:graph, :dependency, :set], agent: agent,
                                            dry_run: dry_run,
                                              force: force,
                                             target: target,
                                            verbose: verbose
    end
  end
end
