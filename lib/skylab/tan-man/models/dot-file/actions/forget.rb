module Skylab::TanMan
  class Models::DotFile::Actions::Forget < Models::DotFile::Action
  private
    def execute
      name = statement.target.words.join ' '
      api_invoke [:graph, :meaning, :forget],  dry_run: dry_run,
                                                 force: force,
                                                  name: name,
                                               verbose: verbose

    end
  end
end
