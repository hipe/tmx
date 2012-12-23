module Skylab::TanMan
  module API::Actions::Graph::Dependency
  end
  class API::Actions::Graph::Dependency::Set < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = [ :agent, :dry_run, :force, :target, :verbose ]

  protected

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        graph = cnt.sexp or break( res = graph )
        if ! graph.stmt_list._prototype
          error "the stmt_list does not have a prototype in #{
            }#{ cnt.graph_noun } (is it at the top, after \"graph {\"?)."
          break( res = false )
        end
        write = nil
        graph.associate! agent, target, prototype: nil do |o|
          o[:existed] = -> x do
            info "association already existed: #{ x.unparse }"
          end
          o[:created] = -> x do
            write = true
            info "created association: #{ x.unparse }"
          end
        end
        if write
          res = cnt.write dry_run, force, verbose
        end
      end while nil
      res
    end
  end
end
