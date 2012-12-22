module Skylab::TanMan
  class Models::DotFile::Actions::Dependency < Models::DotFile::Action
    def execute
      res = nil
      begin
        graph = dotfile_controller.sexp
        break( res = graph ) unless graph
        ok = -> do
          sl = graph.stmt_list
          if ! sl._prototype
            error "the stmt_list does not have a prototype in #{
              }#{ graph_noun } (is it at the top, after \"graph {\"?)."
            break false
          end
          true
        end.call
        break( res = ok ) if ! ok
        agent_str = statement.agent.words.join ' '
        target_str = statement.target.words.join ' '
        do_write = false
        wat = graph.associate! agent_str, target_str, prototype: nil do |o|
          o[:existed] = -> x do
            info "association already existed: #{ x.unparse }"
          end
          o[:created] = -> x do
            do_write = true
            info "created association: #{ x.unparse }"
          end
        end
        if do_write
          res = dotfile_controller.write dry_run, verbose
        end
      end while nil
      res
    end
  end
end
