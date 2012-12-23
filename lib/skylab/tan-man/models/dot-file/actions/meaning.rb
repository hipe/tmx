module Skylab::TanMan
  class Models::DotFile::Actions::Meaning < Models::DotFile::Action
    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        agent = statement.agent.words.join ' '
        target = statement.target.words.join ' '
        write = false
        res = cnt.set_meaning name, value, create, dry_run, verbose,
          nil, dry_run, verbose,
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
          res = dotfile_controller.write dry_run, verbose
        end
      end while nil
      res
    end
  end
end
