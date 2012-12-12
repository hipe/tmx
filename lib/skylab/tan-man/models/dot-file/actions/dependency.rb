module Skylab::TanMan
  class Models::DotFile::Actions::Dependency < ::Struct.new(
    :dotfile_controller,
    :statement
  )
    include Core::SubClient::InstanceMethods # e.g. `initialize`
    extend Headless::Parameter::Controller::StructAdapter
    extend MetaHell::DelegatesTo

    def execute
      res = nil
      begin
        graph = dotfile_controller.sexp or break
        ok = -> do
          sl = graph.stmt_list
          if ! sl._prototype
            error "the stmt_list does not have a prototype in #{
              }#{ graph_noun } (is it at the top, after \"graph {\"?)."
            break false
          end
          true
        end.call
        ok or break
        agent_str = statement.agent.words.join ' '
        target_str = statement.target.words.join ' '
        write = false
        wat = graph.associate! agent_str, target_str, prototype: nil do |o|
          o[:existed] = -> x do
            info "association already existed: #{ x.unparse }"
          end
          o[:created] = -> x do
            write = true
            info "created association: #{ x.unparse }"
          end
        end
        write and dotfile_controller.write
        info "sure ok fine"
      end while nil
      res
    end

  protected

    delegates_to :request_client, :graph_noun

  end
end
