module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Hist_Tree__

      class Bunch__::Finish__

        Callback_::Actor.call self, :properties,
          :bunch, :trail_a

        def execute
          @trail_class = @bunch.repo.class::Hist_Tree__::Bunch__::Trail__
          ok = PROCEDE_
          @trail_a.each do |trail|
            ok = __finish_trail trail
            ok or break
          end
          ok
        end

        def __finish_trail trail
          @trail_class.finish @bunch, trail, & @on_event_selectively
        end
      end
    end
  end
end
