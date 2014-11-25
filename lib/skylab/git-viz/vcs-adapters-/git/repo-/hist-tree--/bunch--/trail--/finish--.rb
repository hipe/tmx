module Skylab::GitViz

  module VCS_Adapters_::Git

    class Repo_::Hist_Tree__

      class Bunch__::Trail__

        Finish__ = Simple_Agent_.new :bunch, :trail, :listener do

          def execute
            @repo = @bunch.repo
            @scn = @trail.get_any_nonzero_count_filediff_stream
            ok = finish_any_filediffs
            ok && @trail.finish
          end
        private
          def finish_any_filediffs
            if @scn
              finish_every_filediff
            else
              PROCEDE_
            end
          end
          def finish_every_filediff
            first_filediff = @scn.gets
            if first_filediff
              finish_each_filediff first_filediff
            else
              PROCEDE_
            end
          end
          def finish_each_filediff filediff
            begin
              filediff.finish_filediff @trail, @listener
              filediff = @scn.gets
            end while filediff
            PROCEDE_
          end
        end
      end
    end
  end
end
