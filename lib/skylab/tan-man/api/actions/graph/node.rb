module Skylab::TanMan
  module API::Actions::Graph::Node
  end

  class API::Actions::Graph::Node::Add < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = [ :dry_run, :force, :name, :verbose ]

  private

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        node = cnt.add_node name, dry_run, force, verbose,
          -> e do # error
            error e.to_h
          end,
          -> e do # success
            info e.to_h
          end
       if node
         res = cnt.write dry_run, force, verbose
       else
         res = false
       end
       res
      end while nil
      res
    end
  end

  class API::Actions::Graph::Node::List < API::Action

    extend API::Action::Parameter_Adapter

    PARAMS = [ :verbose ]

  private

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

  class API::Actions::Graph::Node::Rm < API::Action

    extend API::Action::Parameter_Adapter

    PARAMS = [ :dry_run, :node_ref, :verbose ]

  private

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        destroyed = cnt.rm_node node_ref,
          true, # always fuzzy for now
          -> e do
            error e.to_h
            res = false
          end,
          -> e do
            info e.to_h
            e # we gotta, it becomes `destroyed`
          end
        if destroyed
          res = cnt.write dry_run, true, verbose # always force here
        end
      end while nil
      res
    end
  end
end
