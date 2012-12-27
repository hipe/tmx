module Skylab::TanMan
  module API::Actions::Graph::Node
  end


  class API::Actions::Graph::Node::Add < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = [ :dry_run, :force, :name, :verbose ]

  protected

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        res = cnt.add_node name, dry_run, force, verbose,
          -> e do # error
            error e.to_h
          end,
          -> e do # success
            info e.to_h
          end
      end while nil
      res
    end
  end


  class API::Actions::Graph::Node::List < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = [ :verbose ]

  protected

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        count = 0
        cnt.list_nodes verbose, -> node_stmt do
          count += 1
          payload "#{ lbl node_stmt.label }"
        end
        info "(#{ count } total)"
      end while nil
      res
    end
  end
end
