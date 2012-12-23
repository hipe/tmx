module Skylab::TanMan
  class Models::DotFile::Actions::Meaning < Models::DotFile::Action
  protected
    def execute
      name = statement.agent.words.join ' '
      value = statement.target.words.join ' '

      api_invoke [:graph, :meaning, :learn], create: :both,
                                            dry_run: dry_run,
                                               name: name,
                                              value: value,
                                            verbose: verbose
    end
  end
end
