module Skylab::TanMan
  class Models::DotFile::Actions::Meaning < Models::DotFile::Action
    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        name = statement.agent.words.join ' '
        value = statement.target.words.join ' '
        write = false
        create = nil              # (we don't care whether or not this
                                  # ends up as a `create` or `update`)
        res = cnt.set_meaning name, value, create, dry_run, verbose,
          -> e do
            error e
            false
          end,
          -> success do
            info success
            write = true
            true
          end,
          -> neutral do
            info neutral
            nil
          end
        if write
          res = dotfile_controller.write dry_run, force, verbose
        end
      end while nil
      res
    end
  end
end
