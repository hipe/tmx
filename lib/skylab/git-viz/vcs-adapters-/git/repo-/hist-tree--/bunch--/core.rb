module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Hist_Tree__

      class Bunch__

        def self.build_bunch hist_tree, listener
          Build_Bunch__[ hist_tree, self, listener ]
        end

        Build_Bunch__ = Simple_Agent_.new :hist_tree, :bunch_cls, :listener do

          def execute
            @repo = @hist_tree.repo
            @trail_a = @bunch_cls::Begin__[ self, @listener ]
            @trail_a && finish
          end

          # ~ for children

          def begin_trail line, listener
            @bunch_cls::Trail__.begin self, line, listener
          end

          attr_reader :repo

        private  # ~

          def finish
            ok = @repo.close_the_pool
            ok &&= @bunch_cls::Finish__[ self, @trail_a, @listener ]
            ok && when_OK
          end

          def when_OK
            Bunch__.new @trail_a
          end
        end

        def initialize trail_a
          @trail_a = trail_a ; freeze
        end

        def get_trail_scanner
          d = last = nil
          GitViz_._lib.power_scanner :init, -> do
            d = -1 ; last = @trail_a.length - 1
          end, :gets, -> do
            d < last and @trail_a.fetch d += 1
          end
        end
      end
    end
  end
end
