module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Hist_Tree__

      Bunch__::Finish__ = Simple_Agent_.new :bunch, :trail_a, :listener do

        def execute
          @trail_class = @bunch.repo.class::Hist_Tree__::Bunch__::Trail__
          ok = PROCEDE_
          @trail_a.each do |trail|
            ok = finish_trail trail
            ok or break
          end
          ok
        end
      private
        def finish_trail trail
          @trail_class.finish @bunch, trail, @listener
        end
      end
    end
  end
end
