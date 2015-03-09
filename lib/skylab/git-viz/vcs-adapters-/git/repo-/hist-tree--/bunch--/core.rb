module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Hist_Tree__

      class Bunch__

        class << self

          def build_bunch hist_tree, & oes_p
            Build___[ hist_tree, self, & oes_p ]
          end
        end  # >>

        class Build___

          Callback_::Actor.call self, :properties, :hist_tree, :bunch_cls

          def execute
            @repo = @hist_tree.repo
            @trail_a = @bunch_cls::Begin__[ self, & @on_event_selectively ]
            @trail_a && __finish
          end

          # ~ for children

          def begin_trail line, & oes_p
            @bunch_cls::Trail__.begin self, line, & oes_p
          end

          attr_reader :repo

          def __finish
            ok = @repo.close_the_pool
            ok &&= @bunch_cls::Finish__[ self, @trail_a, & @on_event_selectively ]
            ok && __flush
          end

          def __flush
            Bunch__.new @trail_a
          end
        end

        def initialize trail_a
          @trail_a = trail_a
          freeze
        end

        def get_trail_stream
          d = last = nil
          GitViz_.lib_.power_scanner :init, -> do
            d = -1 ; last = @trail_a.length - 1
          end, :gets, -> do
            d < last and @trail_a.fetch d += 1
          end
        end
      end
    end
  end
end
