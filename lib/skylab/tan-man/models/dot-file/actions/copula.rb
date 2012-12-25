module Skylab::TanMan
  class Models::DotFile::Actions::Copula < Models::DotFile::Action
  protected
    def execute
      node = statement.agent.words.join ' '
      meaning = statement.target.words.join ' '

      api_invoke [:graph, :meaning, :apply], dry_run: dry_run,
                                             meaning: meaning,
                                                node: node,
                                             verbose: verbose
    end
  end
end
