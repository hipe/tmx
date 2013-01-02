module Skylab::TanMan
  module API::Actions::Graph::Association
  end


  class API::Actions::Graph::Association::Add < API::Action
    extend API::Action::Parameter_Adapter

    PARAMS = [ :dry_run, :label, :source_ref, :target_ref ] # verbose hard-coded
                                                            # below!

  protected

    def execute
      res = nil
      begin
        cnt = collections.dot_file.currently_using or break
        res = cnt.add_association source_ref,
          target_ref,
          label,
          -> e { error e.to_h }, # error
          -> e { info e.to_h ; true }   # success
        if res
          res = cnt.write dry_run,
            false, # never force -- assume always we are adding info
            verbose # hard-coded for now (below)!
        end
      end while nil
      res
    end

    def verbose
      true
    end
  end
end
