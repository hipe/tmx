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
        res = cnt.set_dependency agent, target,
          -> e do # error
            error e.to_h
            false
          end,
          -> e do # success
            info e.to_h
            true
          end,
          -> e do # info
            info e.to_h
            nil
          end
        if res
          res = cnt.write dry_run, force, verbose
        end
      end while nil
      res
    end
  end

  class API::Actions::Graph::Dependency::Unset < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = [ :agent, :dry_run, :force, :target, :verbose ]

  protected

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        write = nil
        cnt.disassociate! agent, target,
          -> e do # nodes_not_found
            error e.to_h
          end,
          -> e do # nodes_not_associated
            error e.to_h
          end,
          -> e do # success
            info e.to_h
            write = true
          end
        if write
          res = cnt.write dry_run, force, verbose
        end
      end while nil
      res
    end
  end
end
