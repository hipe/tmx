module Skylab::TanMan
  module Models::Association
    # for now this is just a pure namespace for metadata business-logic
    # like custom events, and associations are represented exclusively
    # as sexps in the document!
  end

  module Models::Association::Events
    # pure namespace, all here
  end


  TanMan::Model::Event || nil # (load it here, then it's prettier below)


  class Models::Association::Events::Created <
    Model::Event.new :edge_stmt

    def build_message
      "created association: #{ edge_stmt.unparse }"
    end
  end


  class Models::Association::Events::Exists <
    Model::Event.new :edge_stmt

    def build_message
      "association already existed: #{ edge_stmt.unparse }"
    end
  end


  class Models::Association::Events::No_Prototype < # this will prob. move
    Model::Event.new :graph_noun

    def build_message
      "the stmt_list does not have a prototype in #{
      }#{ graph_noun } (is it at the top, after \"graph {\"?)."
    end
  end
end
